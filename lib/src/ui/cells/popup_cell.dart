import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class PopupCell extends StatefulWidget {
  final PlutoGridStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;
  final PlutoRow row;

  const PopupCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    Key? key,
  }) : super(key: key);
}

abstract class GridPopupProps {
  List<PlutoColumn> popupColumns = [];

  List<PlutoRow> popupRows = [];

  Icon? icon;
}

mixin PopupCellState<T extends PopupCell> on State<T>
    implements GridPopupProps {
  TextEditingController? _textController;

  FocusNode? _textFocus;

  bool isOpenedPopup = false;

  /// If a column field name is specified,
  /// the value of the field is returned even if another cell is selected.
  ///
  /// If the column field name is not specified,
  /// the value of the selected cell is returned.
  String? fieldOnSelected;

  double? popupHeight;

  int offsetOfScrollRowIdx = 0;

  /// Callback function that returns Header to be inserted at the top of the popup
  /// Implement a callback function that takes [PlutoGridStateManager] as a parameter.
  CreateHeaderCallBack? createHeader;

  /// Callback function that returns Footer to be inserted at the bottom of the popup
  /// Implement a callback function that takes [PlutoGridStateManager] as a parameter.
  CreateFooterCallBack? createFooter;

  @override
  void dispose() {
    widget.stateManager.keyPressed.reset();

    _textController!.dispose();

    _textFocus!.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController()
      ..text =
          widget.column.formattedValueForDisplayInEditing(widget.cell.value);

    _textFocus = FocusNode(onKey: _handleKeyboardFocusOnKey);
  }

  void openPopup() {
    if (widget.column.checkReadOnly(widget.row, widget.cell)) {
      return;
    }

    isOpenedPopup = true;

    PlutoGridPopup(
      context: context,
      mode: PlutoGridMode.select,
      onLoaded: onLoaded,
      onSelected: onSelected,
      columns: popupColumns,
      rows: popupRows,
      width: popupColumns.fold<double>(0, (previous, column) {
            return previous + column.width;
          }) +
          1,
      height: popupHeight,
      createHeader: createHeader,
      createFooter: createFooter,
      configuration: widget.stateManager.configuration?.copyWith(
        gridBorderRadius:
            widget.stateManager.configuration?.gridPopupBorderRadius ??
                BorderRadius.zero,
        defaultColumnTitlePadding: PlutoGridSettings.columnTitlePadding,
        defaultCellPadding: PlutoGridSettings.cellPadding,
        rowHeight: widget.stateManager.configuration!.rowHeight,
        enableRowColorAnimation: false,
      ),
    );
  }

  KeyEventResult _handleKeyboardFocusOnKey(FocusNode node, RawKeyEvent event) {
    var keyManager = PlutoKeyManagerEvent(
      focusNode: node,
      event: event,
    );

    if (keyManager.isKeyUpEvent) {
      return KeyEventResult.handled;
    }

    if (keyManager.isF2 || keyManager.isCharacter) {
      if (isOpenedPopup != true) {
        openPopup();
        return KeyEventResult.handled;
      }
    }

    // 엔터키는 그리드 포커스 핸들러로 전파 한다.
    if (keyManager.isEnter) {
      return KeyEventResult.ignored;
    }

    // KeyManager 로 이벤트 처리를 위임 한다.
    widget.stateManager.keyManager.subject.add(keyManager);

    // 모든 이벤트를 처리 하고 이벤트 전파를 중단한다.
    return KeyEventResult.handled;
  }

  void onLoaded(PlutoGridOnLoadedEvent event) {
    for (var i = 0; i < popupRows.length; i += 1) {
      if (fieldOnSelected == null) {
        for (var entry in popupRows[i].cells.entries) {
          if (popupRows[i].cells[entry.key]!.value == widget.cell.value) {
            event.stateManager.setCurrentCell(
                event.stateManager.refRows[i].cells[entry.key], i);
            break;
          }
        }
      } else {
        if (popupRows[i].cells[fieldOnSelected!]!.value == widget.cell.value) {
          event.stateManager.setCurrentCell(
              event.stateManager.refRows[i].cells[fieldOnSelected!], i);
          break;
        }
      }
    }

    if (event.stateManager.currentRowIdx != null) {
      final rowIdxToMove =
          event.stateManager.currentRowIdx! + 1 + offsetOfScrollRowIdx;

      if (rowIdxToMove < event.stateManager.refRows.length) {
        event.stateManager.moveScrollByRow(PlutoMoveDirection.up, rowIdxToMove);
      } else {
        event.stateManager.moveScrollByRow(
            PlutoMoveDirection.up, event.stateManager.refRows.length);
      }
    }
  }

  void onSelected(PlutoGridOnSelectedEvent event) {
    isOpenedPopup = false;

    dynamic selectedValue;

    if (event.row != null &&
        fieldOnSelected != null &&
        event.row!.cells.containsKey(fieldOnSelected)) {
      selectedValue = event.row!.cells[fieldOnSelected!]!.value;
    } else if (event.cell != null) {
      selectedValue = event.cell!.value;
    } else {
      return;
    }

    handleSelected(selectedValue);
  }

  void handleSelected(dynamic value) {
    widget.stateManager.handleAfterSelectingRow(widget.cell, value);

    _textController!.text = widget.column.formattedValueForDisplayInEditing(
      widget.cell.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stateManager.keepFocus) {
      _textFocus!.requestFocus();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        TextField(
          controller: _textController,
          focusNode: _textFocus,
          readOnly: true,
          textInputAction: TextInputAction.none,
          onTap: openPopup,
          style: widget.stateManager.configuration!.cellTextStyle,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(0),
            isDense: true,
          ),
          maxLines: 1,
          textAlign: widget.column.textAlign.value,
        ),
        Positioned(
          top: -14,
          right: !widget.column.textAlign.isRight ? -10 : null,
          left: widget.column.textAlign.isRight ? -10 : null,
          child: IconButton(
            icon: icon!,
            color: widget.stateManager.configuration!.iconColor,
            iconSize: widget.stateManager.configuration!.iconSize,
            onPressed: openPopup,
          ),
        ),
      ],
    );
  }
}
