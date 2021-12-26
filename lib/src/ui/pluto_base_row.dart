import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBaseRow extends StatelessWidget {
  final PlutoGridStateManager stateManager;
  final int rowIdx;
  final PlutoRow row;
  final List<PlutoColumn> columns;

  const PlutoBaseRow({
    required this.stateManager,
    required this.rowIdx,
    required this.row,
    required this.columns,
    Key? key,
  }) : super(key: key);

  bool _handleOnWillAccept(PlutoRow? draggingRow) {
    if (draggingRow == null) {
      return false;
    }

    final List<PlutoRow> selectedRows =
        stateManager.currentSelectingRows.isNotEmpty
            ? stateManager.currentSelectingRows
            : [draggingRow];

    return selectedRows.firstWhereOrNull(
          (element) => element.key == row.key,
        ) ==
        null;
  }

  void _handleOnMove(DragTargetDetails<PlutoRow> details) async {
    final draggingRows = stateManager.currentSelectingRows.isNotEmpty
        ? stateManager.currentSelectingRows
        : [details.data];

    stateManager.eventManager!.addEvent(
      PlutoGridDragRowsEvent(
        rows: draggingRows,
        targetIdx: rowIdx,
      ),
    );
  }

  PlutoBaseCell _buildCell(PlutoColumn column) {
    return PlutoBaseCell(
      stateManager: stateManager,
      cell: row.cells[column.field]!,
      width: column.width,
      height: stateManager.rowHeight,
      column: column,
      rowIdx: rowIdx,
      row: row,
      key: row.cells[column.field]!.key,
    );
  }

  Widget _dragTargetBuilder(dragContext, candidate, rejected) {
    return _RowContainerWidget(
      stateManager: stateManager,
      rowIdx: rowIdx,
      row: row,
      columns: columns,
      key: ValueKey('rowContainer_${row.key}'),
      child: Row(
        key: ValueKey('rowContainer_${row.key}_row'),
        children: columns.map(_buildCell).toList(growable: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<PlutoRow>(
      onWillAccept: _handleOnWillAccept,
      onMove: _handleOnMove,
      builder: _dragTargetBuilder,
    );
  }
}

class _RowContainerWidget extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  final int rowIdx;

  final PlutoRow row;

  final List<PlutoColumn> columns;

  final Widget child;

  const _RowContainerWidget({
    required this.stateManager,
    required this.rowIdx,
    required this.row,
    required this.columns,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  __RowContainerWidgetState createState() => __RowContainerWidgetState();
}

abstract class __RowContainerWidgetStateWithChangeKeepAlive
    extends PlutoStateWithChangeKeepAlive<_RowContainerWidget> {
  bool? _isCurrentRow;

  bool? _isSelectedRow;

  bool? _isSelecting;

  bool? _isCheckedRow;

  bool? _isDragTarget;

  bool? _isTopDragTarget;

  bool? _isBottomDragTarget;

  bool? _hasCurrentSelectingPosition;

  bool? _isFocusedCurrentRow;

  Color? _rowColor;

  @override
  void onChange() {
    resetState((update) {
      _isCurrentRow = update<bool?>(
        _isCurrentRow,
        widget.stateManager.currentRowIdx == widget.rowIdx,
      );

      _isSelectedRow = update<bool?>(
        _isSelectedRow,
        widget.stateManager.isSelectedRow(widget.row.key),
      );

      _isSelecting =
          update<bool?>(_isSelecting, widget.stateManager.isSelecting);

      _isCheckedRow = update<bool?>(_isCheckedRow, widget.row.checked);

      final alreadyTarget = widget.stateManager.dragRows
              .firstWhereOrNull((element) => element.key == widget.row.key) !=
          null;

      final isDraggingRow = widget.stateManager.isDraggingRow;

      _isDragTarget = update<bool?>(
        _isDragTarget,
        !alreadyTarget && widget.stateManager.isRowIdxDragTarget(widget.rowIdx),
        ignoreChange: !isDraggingRow,
      );

      _isTopDragTarget = update<bool?>(
        _isTopDragTarget,
        isDraggingRow &&
            widget.stateManager.isRowIdxTopDragTarget(widget.rowIdx),
      );

      _isBottomDragTarget = update<bool?>(
        _isBottomDragTarget,
        isDraggingRow &&
            widget.stateManager.isRowIdxBottomDragTarget(widget.rowIdx),
      );

      _hasCurrentSelectingPosition = update<bool?>(
        _hasCurrentSelectingPosition,
        widget.stateManager.hasCurrentSelectingPosition,
      );

      _isFocusedCurrentRow = update<bool?>(
        _isFocusedCurrentRow,
        _isCurrentRow! && widget.stateManager.hasFocus,
      );

      _rowColor = update<Color?>(_rowColor, _getRowColor());

      if (widget.stateManager.mode.isNormal) {
        setKeepAlive(widget.stateManager.isRowBeingDragged(widget.row.key));
      }
    });
  }

  Color _getDefaultRowColor() {
    if (widget.stateManager.rowColorCallback == null) {
      return widget.stateManager.configuration!.gridBackgroundColor;
    }

    return widget.stateManager.rowColorCallback!(
      PlutoRowColorContext(
        rowIdx: widget.rowIdx,
        row: widget.row,
        stateManager: widget.stateManager,
      ),
    );
  }

  Color _getRowColor() {
    Color color = _getDefaultRowColor();

    if (_isDragTarget!) {
      color = widget.stateManager.configuration!.cellColorInReadOnlyState;
    } else {
      final bool checkCurrentRow = !widget.stateManager.selectingMode.isRow &&
          _isFocusedCurrentRow! &&
          (!_isSelecting! && !_hasCurrentSelectingPosition!);

      final bool checkSelectedRow = widget.stateManager.selectingMode.isRow &&
          widget.stateManager.isSelectedRow(widget.row.key);

      if (checkCurrentRow || checkSelectedRow) {
        color = widget.stateManager.configuration!.activatedColor;
      }
    }

    return _isCheckedRow!
        ? Color.alphaBlend(
            widget.stateManager.configuration!.checkedColor,
            color,
          )
        : color;
  }

  BoxDecoration _getBoxDecoration() {
    return BoxDecoration(
      color: _rowColor,
      border: Border(
        top: _isTopDragTarget!
            ? BorderSide(
                width: PlutoGridSettings.rowBorderWidth,
                color: widget.stateManager.configuration!.activatedBorderColor,
              )
            : BorderSide.none,
        bottom: BorderSide(
          width: PlutoGridSettings.rowBorderWidth,
          color: _isBottomDragTarget!
              ? widget.stateManager.configuration!.activatedBorderColor
              : widget.stateManager.configuration!.borderColor,
        ),
      ),
    );
  }
}

class __RowContainerWidgetState
    extends __RowContainerWidgetStateWithChangeKeepAlive {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final _decoration = _getBoxDecoration();

    return _AnimatedOrNormalContainer(
      enable: widget.stateManager.configuration!.enableRowColorAnimation,
      child: widget.child,
      decoration: _decoration,
    );
  }
}

class _AnimatedOrNormalContainer extends StatelessWidget {
  final bool enable;

  final Widget child;

  final BoxDecoration decoration;

  const _AnimatedOrNormalContainer({
    required this.enable,
    required this.child,
    required this.decoration,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return enable
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: decoration,
            child: child,
          )
        : Container(
            decoration: decoration,
            child: child,
          );
  }
}
