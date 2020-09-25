part of '../../../pluto_grid.dart';

abstract class IScrollState {
  /// Controller to control the scrolling of the grid.
  PlutoScrollController get scroll;

  PlutoScrollController _scroll;

  /// [direction] Scroll direction
  /// [offset] Scroll position
  void scrollByDirection(MoveDirection direction, double offset);

  /// Whether the cell can be scrolled when moving.
  bool canHorizontalCellScrollByDirection(
    MoveDirection direction,
    PlutoColumn columnToMove,
  );

  /// Scroll to [rowIdx] position.
  void moveScrollByRow(MoveDirection direction, int rowIdx);

  /// Scroll to [columnIdx] position.
  void moveScrollByColumn(MoveDirection direction, int columnIdx);
}

mixin ScrollState implements IPlutoState {
  PlutoScrollController get scroll => _scroll;

  PlutoScrollController _scroll;

  void scrollByDirection(MoveDirection direction, double offset) {
    if (direction.vertical) {
      _scroll.vertical.jumpTo(offset);
    } else {
      _scroll.horizontal.jumpTo(offset);
    }
  }

  bool canHorizontalCellScrollByDirection(
    MoveDirection direction,
    PlutoColumn columnToMove,
  ) {
    // 고정 컬럼이 보여지는 상태에서 이동 할 컬럼이 고정 컬럼인 경우 스크롤 불필요
    return !(layout.showFixedColumn == true && columnToMove.fixed.isFixed);
  }

  void moveScrollByRow(MoveDirection direction, int rowIdx) {
    if (!direction.vertical) {
      return;
    }

    final double rowSize = PlutoDefaultSettings.rowTotalHeight;

    final double gridOffset =
        PlutoDefaultSettings.gridPadding + PlutoDefaultSettings.shadowLineSize;

    final double screenOffset =
        _scroll.vertical.offset + layout.offsetHeight - rowSize - gridOffset;

    double offsetToMove =
        direction.isUp ? (rowIdx - 1) * rowSize : (rowIdx + 1) * rowSize;

    final bool inScrollStart = _scroll.vertical.offset <= offsetToMove;

    final bool inScrollEnd = offsetToMove + rowSize <= screenOffset;

    if (inScrollStart && inScrollEnd) {
      return;
    } else if (inScrollEnd == false) {
      offsetToMove =
          _scroll.vertical.offset + offsetToMove + rowSize - screenOffset;
    }

    scrollByDirection(direction, offsetToMove);
  }

  void moveScrollByColumn(MoveDirection direction, int columnIdx) {
    if (!direction.horizontal) {
      return;
    }

    final PlutoColumn columnToMove =
        _columns[columnIndexesForShowFixed[columnIdx + direction.offset]];

    if (!canHorizontalCellScrollByDirection(
      direction,
      columnToMove,
    )) {
      return;
    }

    // 이동할 스크롤 포지션 계산을 위해 이동 할 컬럼까지의 넓이 합계를 구한다.
    double offsetToMove = layout.showFixedColumn == true
        ? bodyColumnsWidthAtColumnIdx(
            columnIdx + direction.offset - leftFixedColumnIndexes.length)
        : columnsWidthAtColumnIdx(columnIdx + direction.offset);

    final double screenOffset = layout.showFixedColumn == true
        ? layout.maxWidth - leftFixedColumnsWidth - rightFixedColumnsWidth
        : layout.maxWidth;

    if (direction.isRight) {
      if (offsetToMove > _scroll.horizontal.offset) {
        offsetToMove -= screenOffset;
        offsetToMove += PlutoDefaultSettings.totalShadowLineWidth;
        offsetToMove += columnToMove.width;

        if (offsetToMove < _scroll.horizontal.offset) {
          return;
        }
      }
    } else {
      final offsetToNeed = offsetToMove +
          columnToMove.width +
          PlutoDefaultSettings.totalShadowLineWidth;

      final currentOffset = screenOffset + _scroll.horizontal.offset;

      if (offsetToNeed > currentOffset) {
        offsetToMove = _scroll.horizontal.offset + offsetToNeed - currentOffset;
      } else if (offsetToMove > _scroll.horizontal.offset) {
        return;
      }
    }

    scrollByDirection(direction, offsetToMove);
  }
}
