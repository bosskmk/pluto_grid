part of '../../../pluto_grid.dart';

abstract class ILayoutState {
  /// Screen size, fixed column visibility.
  PlutoLayout get layout;

  /// Global offset of Grid.
  Offset get gridGlobalOffset;

  /// Update screen size information when LayoutBuilder builds.
  void setLayout(BoxConstraints size, double headerHeight, double footerHeight);
}

mixin LayoutState implements IPlutoState {
  PlutoLayout get layout => _layout;

  PlutoLayout _layout = PlutoLayout();

  Offset get gridGlobalOffset {
    if (_gridGlobalOffset != null) {
      return _gridGlobalOffset;
    }

    if (gridKey == null) {
      return null;
    }

    final RenderBox gridRenderBox = gridKey.currentContext?.findRenderObject();

    if (gridRenderBox == null) {
      return null;
    }

    _gridGlobalOffset = gridRenderBox.localToGlobal(Offset.zero);

    return _gridGlobalOffset;
  }

  Offset _gridGlobalOffset;

  void setLayout(
      BoxConstraints size, double headerHeight, double footerHeight) {
    final _isShowFixedColumn = isShowFixedColumn(size.maxWidth);

    final bool notify = _layout.showFixedColumn != _isShowFixedColumn;

    _layout.maxWidth = size.maxWidth;
    _layout.maxHeight = size.maxHeight;
    _layout.showFixedColumn = _isShowFixedColumn;
    _layout.headerHeight = headerHeight;
    _layout.footerHeight = footerHeight;

    _gridGlobalOffset = null;

    if (notify) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
}