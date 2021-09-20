import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IScrollState {
  /// Controller to control the scrolling of the grid.
  PlutoGridScrollController? get scroll;

  void setScroll(PlutoGridScrollController scroll);

  /// [direction] Scroll direction
  /// [offset] Scroll position
  void scrollByDirection(PlutoMoveDirection direction, double offset);

  /// Whether the cell can be scrolled when moving.
  bool canHorizontalCellScrollByDirection(
    PlutoMoveDirection direction,
    PlutoColumn columnToMove,
  );

  /// Scroll to [rowIdx] position.
  void moveScrollByRow(PlutoMoveDirection direction, int? rowIdx);

  /// Scroll to [columnIdx] position.
  void moveScrollByColumn(PlutoMoveDirection direction, int? columnIdx);

  bool needMovingScroll(Offset offset, PlutoMoveDirection move);
}

mixin ScrollState implements IPlutoGridState {
  PlutoGridScrollController? get scroll => _scroll;

  PlutoGridScrollController? _scroll;

  void setScroll(PlutoGridScrollController? scroll) {
    _scroll = scroll;
  }

  void scrollByDirection(PlutoMoveDirection direction, double offset) {
    if (direction.vertical) {
      _scroll!.vertical!.jumpTo(offset);
    } else {
      _scroll!.horizontal!.jumpTo(offset);
    }
  }

  bool canHorizontalCellScrollByDirection(
    PlutoMoveDirection direction,
    PlutoColumn columnToMove,
  ) {
    // 고정 컬럼이 보여지는 상태에서 이동 할 컬럼이 고정 컬럼인 경우 스크롤 불필요
    return !(showFrozenColumn == true && columnToMove.frozen.isFrozen);
  }

  void moveScrollByRow(PlutoMoveDirection direction, int? rowIdx) {
    if (!direction.vertical) {
      return;
    }

    final double rowSize = rowTotalHeight;

    final double gridOffset = (configuration?.settings.gridPadding ??
            PlutoGridSettings.defaultGridPadding) +
        (configuration?.settings.shadowLineSize ??
            PlutoGridSettings.defaultShadowLineSize);

    final double screenOffset = _scroll!.verticalOffset +
        offsetHeight -
        columnHeight -
        columnFilterHeight -
        gridOffset;

    double offsetToMove =
        direction.isUp ? (rowIdx! - 1) * rowSize : (rowIdx! + 1) * rowSize;

    final bool inScrollStart = _scroll!.verticalOffset <= offsetToMove;

    final bool inScrollEnd = offsetToMove + rowSize <= screenOffset;

    if (inScrollStart && inScrollEnd) {
      return;
    } else if (inScrollEnd == false) {
      offsetToMove =
          _scroll!.verticalOffset + offsetToMove + rowSize - screenOffset;
    }

    scrollByDirection(direction, offsetToMove);
  }

  void moveScrollByColumn(PlutoMoveDirection direction, int? columnIdx) {
    if (!direction.horizontal) {
      return;
    }

    final columnIndexes = columnIndexesByShowFrozen;

    final PlutoColumn columnToMove =
        refColumns![columnIndexes[columnIdx! + direction.offset]];

    if (!canHorizontalCellScrollByDirection(
      direction,
      columnToMove,
    )) {
      return;
    }

    // 이동할 스크롤 포지션 계산을 위해 이동 할 컬럼까지의 넓이 합계를 구한다.
    double offsetToMove = showFrozenColumn == true
        ? bodyColumnsWidthAtColumnIdx(
            columnIdx + direction.offset - leftFrozenColumnIndexes.length)
        : columnsWidthAtColumnIdx(columnIdx + direction.offset);

    final double? screenOffset = showFrozenColumn == true
        ? maxWidth! - leftFrozenColumnsWidth - rightFrozenColumnsWidth
        : maxWidth;

    if (direction.isRight) {
      if (offsetToMove > _scroll!.horizontal!.offset) {
        offsetToMove -= screenOffset!;
        offsetToMove += configuration?.settings.totalShadowLineWidth ??
            PlutoGridSettings.defaultTotalShadowLineWidth;
        offsetToMove += columnToMove.width;
        offsetToMove += scrollOffsetByFrozenColumn;

        if (offsetToMove < _scroll!.horizontal!.offset) {
          return;
        }
      }
    } else {
      final offsetToNeed = offsetToMove +
          columnToMove.width +
          (configuration?.settings.totalShadowLineWidth ??
              PlutoGridSettings.defaultTotalShadowLineWidth);

      final currentOffset = screenOffset! + _scroll!.horizontal!.offset;

      if (offsetToNeed > currentOffset) {
        offsetToMove =
            _scroll!.horizontal!.offset + offsetToNeed - currentOffset;
        offsetToMove += scrollOffsetByFrozenColumn;
      } else if (offsetToMove > _scroll!.horizontal!.offset) {
        return;
      }
    }

    scrollByDirection(direction, offsetToMove);
  }

  bool needMovingScroll(Offset? offset, PlutoMoveDirection move) {
    if (selectingMode.isNone) {
      return false;
    }

    switch (move) {
      case PlutoMoveDirection.left:
        return offset!.dx < bodyLeftScrollOffset;
      case PlutoMoveDirection.right:
        return offset!.dx > bodyRightScrollOffset;
      case PlutoMoveDirection.up:
        return offset!.dy < bodyUpScrollOffset;
      case PlutoMoveDirection.down:
        return offset!.dy > bodyDownScrollOffset;
    }
  }
}
