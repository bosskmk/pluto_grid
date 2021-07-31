import 'package:pluto_grid/pluto_grid.dart';

abstract class IPaginationRowState {
  int get page;

  int get pageSize;

  int get totalPage;

  void setPageSize(int pageSize, {bool notify = true});

  void setPage(int page, {bool notify = true});
}

mixin PaginationRowState implements IPlutoGridState {
  static int defaultPageSize = 40;

  int _pageSize = defaultPageSize;

  int _page = 1;

  final FilteredListRange _range = FilteredListRange(0, defaultPageSize);

  int get _length =>
      hasFilter ? refRows!.filteredList.length : refRows!.originalList.length;

  int get page => _page;

  int get pageSize => _pageSize;

  int get totalPage {
    return (_length / _pageSize).ceil();
  }

  void setPageSize(int pageSize, {bool notify = true}) {
    _pageSize = pageSize;

    if (notify) {
      notifyListeners();
    }
  }

  void setPage(int page, {bool notify = true}) {
    _page = page;

    int from = (page - 1) * _pageSize;

    int to = page * _pageSize;

    if (to > _length) {
      to = _length;
    }

    _range.setRange(from, to);

    refRows!.setFilterRange(_range);

    if (notify) {
      notifyListeners();
    }
  }
}
