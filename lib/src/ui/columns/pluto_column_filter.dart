import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoColumnFilter extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  final PlutoColumn column;

  const PlutoColumnFilter({
    required this.stateManager,
    required this.column,
    Key? key,
  }) : super(key: key);

  @override
  _PlutoColumnFilterState createState() => _PlutoColumnFilterState();
}

abstract class _PlutoColumnFilterStateWithChange
    extends PlutoStateWithChange<PlutoColumnFilter> {
  FocusNode? focusNode;

  TextEditingController? controller;

  List<PlutoRow?>? filterRows;

  String? text;

  bool? enabled;

  late StreamSubscription event;

  String get filterValue {
    return filterRows!.isEmpty
        ? ''
        : filterRows!.first!.cells[FilterHelper.filterFieldValue]!.value
            .toString();
  }

  bool get hasCompositeFilter {
    return filterRows!.length > 1 ||
        widget.stateManager
            .filterRowsByField(FilterHelper.filterFieldAllColumns)
            .isNotEmpty;
  }

  @override
  initState() {
    super.initState();

    focusNode = FocusNode(onKey: handleOnKey);

    widget.column.setFilterFocusNode(focusNode);

    controller = TextEditingController(text: filterValue);

    event = widget.stateManager.eventManager!.listener(handleFocusFromRows);
  }

  @override
  dispose() {
    event.cancel();

    controller!.dispose();

    focusNode!.dispose();

    super.dispose();
  }

  @override
  void onChange() {
    resetState((update) {
      filterRows = update<List<PlutoRow?>?>(
        filterRows,
        widget.stateManager.filterRowsByField(widget.column.field),
        compare: listEquals,
      );

      if (focusNode?.hasPrimaryFocus != true) {
        text = update<String?>(text, filterValue);

        if (changed) {
          controller?.text = text!;
        }
      }

      enabled = update<bool?>(
        enabled,
        widget.column.enableFilterMenuItem && !hasCompositeFilter,
      );
    });
  }

  void moveDown({required bool focusToPreviousCell}) {
    focusNode?.unfocus();

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

  KeyEventResult handleOnKey(FocusNode node, RawKeyEvent event) {
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
        (controller!.text.isEmpty && keyManager.isHorizontal);

    final skip = !(handleMoveDown || handleMoveHorizontal || keyManager.isF3);

    if (skip) {
      /// 2021-11-19
      /// KeyEventResult.skipRemainingHandlers 동작 오류로 인한 임시 코드
      /// 이슈 해결 후 : 삭제
      if (keyManager.isUp) {
        return KeyEventResult.handled;
      }

      /// 2021-11-19
      /// KeyEventResult.skipRemainingHandlers 동작 오류로 인한 임시 코드
      /// 이슈 해결 후 :
      /// ```dart
      /// return KeyEventResult.skipRemainingHandlers;
      /// ```
      return widget.stateManager.keyManager!.eventResult.skip(
        KeyEventResult.ignored,
      );
    }

    if (handleMoveDown) {
      moveDown(focusToPreviousCell: keyManager.isEsc);
    } else if (handleMoveHorizontal) {
      widget.stateManager.nextFocusOfColumnFilter(
        widget.column,
        reversed: keyManager.isLeft || keyManager.isShiftPressed,
      );
    } else if (keyManager.isF3) {
      widget.stateManager.showFilterPopup(
        focusNode!.context!,
        calledColumn: widget.column,
      );
    }

    return KeyEventResult.handled;
  }

  void handleFocusFromRows(PlutoGridEvent plutoEvent) {
    if (!enabled!) {
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
        focusNode!.requestFocus();
      }
    }
  }
}

class _PlutoColumnFilterState extends _PlutoColumnFilterStateWithChange {
  InputBorder get border => OutlineInputBorder(
        borderSide: BorderSide(
            color: widget.stateManager.configuration!.borderColor, width: 0.0),
        borderRadius: BorderRadius.zero,
      );

  InputBorder get enabledBorder => OutlineInputBorder(
        borderSide: BorderSide(
            color: widget.stateManager.configuration!.activatedBorderColor,
            width: 0.0),
        borderRadius: BorderRadius.zero,
      );

  Color get textFieldColor => enabled!
      ? widget.stateManager.configuration!.cellColorInEditState
      : widget.stateManager.configuration!.cellColorInReadOnlyState;

  double get padding =>
      widget.column.titlePadding ??
      widget.stateManager.configuration!.defaultColumnTitlePadding;

  void handleOnTap() {
    widget.stateManager.setKeepFocus(false);
  }

  void handleOnChanged(String changed) {
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

  void handleOnEditingComplete() {
    // empty for ignore event of OnEditingComplete.
  }

  @override
  Widget build(BuildContext context) {
    final configuration = widget.stateManager.configuration!;

    return Container(
      width: widget.column.width,
      height: widget.stateManager.columnFilterHeight,
      padding: EdgeInsets.symmetric(horizontal: padding),
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
      child: Align(
        alignment: Alignment.center,
        child: Stack(
          children: [
            TextField(
              focusNode: focusNode,
              controller: controller,
              enabled: enabled,
              style: configuration.cellTextStyle,
              onTap: handleOnTap,
              onChanged: handleOnChanged,
              onEditingComplete: handleOnEditingComplete,
              decoration: InputDecoration(
                hintText: enabled! ? widget.column.defaultFilter.title : '',
                isDense: true,
                filled: true,
                fillColor: textFieldColor,
                border: border,
                enabledBorder: border,
                focusedBorder: enabledBorder,
                contentPadding: const EdgeInsets.symmetric(vertical: 5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
