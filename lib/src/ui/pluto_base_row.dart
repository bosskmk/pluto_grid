import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class PlutoBaseRow extends StatelessWidget {
  final int rowIdx;

  final PlutoRow row;

  final List<PlutoColumn> columns;

  const PlutoBaseRow({
    required this.rowIdx,
    required this.row,
    required this.columns,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stateManager = context.read<PlutoGridStateManager>();

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

    Widget _dragTargetBuilder(dragContext, candidate, rejected) {
      return _RowContainerWidget(
        rowIdx: rowIdx,
        row: row,
        enableRowColorAnimation:
            stateManager.configuration!.enableRowColorAnimation,
        key: ValueKey('rowContainer_${row.key}'),
        child: CustomMultiChildLayout(
          key: ValueKey('rowContainer_${row.key}_row'),
          delegate: _RowCellsLayoutDelegate(
            stateManager: stateManager,
            columns: columns,
          ),
          children: columns.map(_buildCell).toList(growable: false),
        ),
      );
    }

    return DragTarget<PlutoRow>(
      onWillAccept: _handleOnWillAccept,
      onMove: _handleOnMove,
      builder: _dragTargetBuilder,
    );
  }

  Widget _buildCell(PlutoColumn column) {
    return LayoutId(
      id: column.field,
      child: Builder(
        builder: (buildContext) {
          buildContext.select<PlutoGridStateManager, bool>(
            (value) => column.visible,
          );

          return Visibility(
            visible: column.visible,
            child: PlutoBaseCell(
              cell: row.cells[column.field]!,
              column: column,
              rowIdx: rowIdx,
              row: row,
              key: row.cells[column.field]!.key,
            ),
          );
        },
      ),
    );
  }
}

class _RowCellsLayoutDelegate extends MultiChildLayoutDelegate {
  final PlutoGridStateManager stateManager;

  final List<PlutoColumn> columns;

  _RowCellsLayoutDelegate({
    required this.stateManager,
    required this.columns,
  });

  @override
  Size getSize(BoxConstraints constraints) {
    final double width = columns.fold(
      0,
      (previousValue, element) => previousValue + element.width,
    );

    return Size(width, stateManager.rowHeight);
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }

  @override
  void performLayout(Size size) {
    double dx = 0;

    for (var element in columns) {
      if (!hasChild(element.field)) continue;

      var width = element.width;

      layoutChild(
        element.field,
        BoxConstraints.tightFor(
          width: width,
          height: stateManager.rowHeight,
        ),
      );

      positionChild(
        element.field,
        Offset(dx, 0),
      );

      dx += width;
    }
  }
}

class _RowContainerWidget extends StatelessWidget {
  final int rowIdx;

  final PlutoRow row;

  final bool enableRowColorAnimation;

  final Widget child;

  const _RowContainerWidget({
    required this.rowIdx,
    required this.row,
    required this.enableRowColorAnimation,
    required this.child,
    Key? key,
  }) : super(key: key);

  Color _getDefaultRowColor(PlutoGridStateManager stateManager) {
    if (stateManager.rowColorCallback == null) {
      return stateManager.configuration!.gridBackgroundColor;
    }

    return stateManager.rowColorCallback!(
      PlutoRowColorContext(
        rowIdx: rowIdx,
        row: row,
        stateManager: stateManager,
      ),
    );
  }

  Color _getRowColor({
    required PlutoGridStateManager stateManager,
    required bool isDragTarget,
    required bool isFocusedCurrentRow,
    required bool isSelecting,
    required bool hasCurrentSelectingPosition,
    required bool isCheckedRow,
  }) {
    Color color = _getDefaultRowColor(stateManager);

    if (isDragTarget) {
      color = stateManager.configuration!.cellColorInReadOnlyState;
    } else {
      final bool checkCurrentRow = !stateManager.selectingMode.isRow &&
          isFocusedCurrentRow &&
          (!isSelecting && !hasCurrentSelectingPosition);

      final bool checkSelectedRow = stateManager.selectingMode.isRow &&
          stateManager.isSelectedRow(row.key);

      if (checkCurrentRow || checkSelectedRow) {
        color = stateManager.configuration!.activatedColor;
      }
    }

    return isCheckedRow
        ? Color.alphaBlend(stateManager.configuration!.checkedColor, color)
        : color;
  }

  BoxDecoration _getBoxDecoration(PlutoGridStateManager stateManager) {
    final bool isCurrentRow = stateManager.currentRowIdx == rowIdx;

    final bool isSelecting = stateManager.isSelecting;

    final bool isCheckedRow = row.checked == true;

    final alreadyTarget = stateManager.dragRows
            .firstWhereOrNull((element) => element.key == row.key) !=
        null;

    final isDraggingRow = stateManager.isDraggingRow;

    final bool isDragTarget = isDraggingRow &&
        !alreadyTarget &&
        stateManager.isRowIdxDragTarget(rowIdx);

    final bool isTopDragTarget =
        isDraggingRow && stateManager.isRowIdxTopDragTarget(rowIdx);

    final bool isBottomDragTarget =
        isDraggingRow && stateManager.isRowIdxBottomDragTarget(rowIdx);

    final bool hasCurrentSelectingPosition =
        stateManager.hasCurrentSelectingPosition;

    final bool isFocusedCurrentRow = isCurrentRow && stateManager.hasFocus;

    final Color rowColor = _getRowColor(
      stateManager: stateManager,
      isDragTarget: isDragTarget,
      isFocusedCurrentRow: isFocusedCurrentRow,
      isSelecting: isSelecting,
      hasCurrentSelectingPosition: hasCurrentSelectingPosition,
      isCheckedRow: isCheckedRow,
    );

    return BoxDecoration(
      color: rowColor,
      border: Border(
        top: isTopDragTarget
            ? BorderSide(
                width: PlutoGridSettings.rowBorderWidth,
                color: stateManager.configuration!.activatedBorderColor,
              )
            : BorderSide.none,
        bottom: BorderSide(
          width: PlutoGridSettings.rowBorderWidth,
          color: isBottomDragTarget
              ? stateManager.configuration!.activatedBorderColor
              : stateManager.configuration!.borderColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<PlutoGridStateManager, BoxDecoration>(
      update: (_, stateManager, __) => _getBoxDecoration(stateManager),
      child: Consumer<BoxDecoration>(
        builder: (_, decoration, child) {
          return _AnimatedOrNormalContainer(
            enable: enableRowColorAnimation,
            decoration: decoration,
            child: child!,
          );
        },
        child: child,
      ),
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
