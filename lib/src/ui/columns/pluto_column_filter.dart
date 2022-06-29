import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoColumnFilter extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  final PlutoColumn column;

  PlutoColumnFilter({
    required this.stateManager,
    required this.column,
    Key? key,
  }) : super(key: ValueKey('column_filter_${column.key}'));

  @override
  PlutoColumnFilterState createState() => PlutoColumnFilterState();
}

class PlutoColumnFilterState extends PlutoStateWithChange<PlutoColumnFilter> {
  List<PlutoRow> _filterRows = [];

  String _text = '';

  bool _enabled = false;

  late final StreamSubscription _event;

  late final FocusNode _focusNode;

  late final TextEditingController _controller;

  String get _filterValue {
    return _filterRows.isEmpty
        ? ''
        : _filterRows.first.cells[FilterHelper.filterFieldValue]!.value
            .toString();
  }

  bool get _hasCompositeFilter {
    return _filterRows.length > 1 ||
        widget.stateManager
            .filterRowsByField(FilterHelper.filterFieldAllColumns)
            .isNotEmpty;
  }

  InputBorder get _border => OutlineInputBorder(
        borderSide: BorderSide(
            color: widget.stateManager.configuration!.borderColor, width: 0.0),
        borderRadius: BorderRadius.zero,
      );

  InputBorder get _enabledBorder => OutlineInputBorder(
        borderSide: BorderSide(
            color: widget.stateManager.configuration!.activatedBorderColor,
            width: 0.0),
        borderRadius: BorderRadius.zero,
      );

  Color get _textFieldColor => _enabled
      ? widget.stateManager.configuration!.cellColorInEditState
      : widget.stateManager.configuration!.cellColorInReadOnlyState;

  EdgeInsets get _padding =>
      widget.column.titlePadding ??
      widget.stateManager.configuration!.defaultColumnTitlePadding;

  @override
  initState() {
    super.initState();

    _focusNode = FocusNode(onKey: _handleOnKey);

    widget.column.setFilterFocusNode(_focusNode);

    _controller = TextEditingController(text: _filterValue);

    _event = widget.stateManager.eventManager!.listener(_handleFocusFromRows);

    updateState();
  }

  @override
  dispose() {
    _event.cancel();

    _controller.dispose();

    _focusNode.dispose();

    super.dispose();
  }

  @override
  void updateState() {
    _filterRows = update<List<PlutoRow>>(
      _filterRows,
      widget.stateManager.filterRowsByField(widget.column.field),
      compare: listEquals,
    );

    if (_focusNode.hasPrimaryFocus != true) {
      _text = update<String>(_text, _filterValue);

      if (changed) {
        _controller.text = _text;
      }
    }

    _enabled = update<bool>(
      _enabled,
      widget.column.enableFilterMenuItem && !_hasCompositeFilter,
    );
  }

  void _moveDown({required bool focusToPreviousCell}) {
    _focusNode.unfocus();

    if (!focusToPreviousCell || widget.stateManager.currentCell == null) {
      widget.stateManager.setCurrentCell(
        widget.stateManager.refRows.first.cells[widget.column.field],
        0,
        notify: false,
      );

      widget.stateManager.scrollByDirection(PlutoMoveDirection.down, 0);
    }

    widget.stateManager.setKeepFocus(true, notify: false);

    widget.stateManager.notifyListeners();
  }

  KeyEventResult _handleOnKey(FocusNode node, RawKeyEvent event) {
    var keyManager = PlutoKeyManagerEvent(
      focusNode: node,
      event: event,
    );

    if (keyManager.isKeyUpEvent) {
      return KeyEventResult.handled;
    }

    final handleMoveDown =
        (keyManager.isDown || keyManager.isEnter || keyManager.isEsc) &&
            widget.stateManager.refRows.isNotEmpty;

    final handleMoveHorizontal = keyManager.isTab ||
        (_controller.text.isEmpty && keyManager.isHorizontal);

    final skip = !(handleMoveDown || handleMoveHorizontal || keyManager.isF3);

    if (skip) {
      if (keyManager.isUp) {
        return KeyEventResult.handled;
      }

      return widget.stateManager.keyManager!.eventResult.skip(
        KeyEventResult.ignored,
      );
    }

    if (handleMoveDown) {
      _moveDown(focusToPreviousCell: keyManager.isEsc);
    } else if (handleMoveHorizontal) {
      widget.stateManager.nextFocusOfColumnFilter(
        widget.column,
        reversed: keyManager.isLeft || keyManager.isShiftPressed,
      );
    } else if (keyManager.isF3) {
      widget.stateManager.showFilterPopup(
        _focusNode.context!,
        calledColumn: widget.column,
      );
    }

    return KeyEventResult.handled;
  }

  void _handleFocusFromRows(PlutoGridEvent plutoEvent) {
    if (!_enabled) {
      return;
    }

    if (plutoEvent is PlutoGridCannotMoveCurrentCellEvent &&
        plutoEvent.direction.isUp) {
      var isCurrentColumn = widget
              .stateManager
              .refColumns[widget.stateManager.columnIndexesByShowFrozen[
                  plutoEvent.cellPosition.columnIdx!]]
              .key ==
          widget.column.key;

      if (isCurrentColumn) {
        widget.stateManager.clearCurrentCell(notify: false);
        widget.stateManager.setKeepFocus(false);
        _focusNode.requestFocus();
      }
    }
  }

  void _handleOnTap() {
    widget.stateManager.setKeepFocus(false);
  }

  void _handleOnChanged(String changed) {
    widget.stateManager.eventManager!.addEvent(
      PlutoGridChangeColumnFilterEvent(
        column: widget.column,
        filterType: widget.column.defaultFilter,
        filterValue: changed,
        debounceMilliseconds: widget.stateManager.configuration!
            .columnFilterConfig.debounceMilliseconds,
      ),
    );
  }

  void _handleOnEditingComplete() {
    // empty for ignore event of OnEditingComplete.
  }

  @override
  Widget build(BuildContext context) {
    final configuration = widget.stateManager.configuration!;

    return Container(
      height: widget.stateManager.columnFilterHeight,
      padding: _padding,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: configuration.borderColor,
          ),
          right: configuration.enableColumnBorder
              ? BorderSide(
                  color: configuration.borderColor,
                )
              : BorderSide.none,
        ),
      ),
      child: Center(
        child: TextField(
          focusNode: _focusNode,
          controller: _controller,
          enabled: _enabled,
          style: configuration.cellTextStyle,
          onTap: _handleOnTap,
          onChanged: _handleOnChanged,
          onEditingComplete: _handleOnEditingComplete,
          decoration: InputDecoration(
            hintText: _enabled ? widget.column.defaultFilter.title : '',
            isDense: true,
            filled: true,
            fillColor: _textFieldColor,
            border: _border,
            enabledBorder: _border,
            focusedBorder: _enabledBorder,
            contentPadding: const EdgeInsets.symmetric(vertical: 5),
          ),
        ),
      ),
    );
  }
}
