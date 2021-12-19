import 'package:pluto_grid/pluto_grid.dart';

abstract class IPaginationRowState {
  int get page;

  int get pageSize;

  int get totalPage;

  bool get isPaginated;

  void setPageSize(int pageSize, {bool notify = true});

  void setPage(int page, {bool notify = true});

  void resetPage({bool notify = true});
}

mixin PaginationRowState implements IPlutoGridState {
  static int defaultPageSize = 40;

  int _pageSize = defaultPageSize;

  int _page = 1;

  final FilteredListRange _range = FilteredListRange(0, defaultPageSize);

  int get _length =>
      hasFilter ? refRows!.filteredList.length : refRows!.originalList.length;

  int get _adjustPage {
    if (page > totalPage) {
      return totalPage;
    }

    if (page < 1 && totalPage > 0) {
      return 1;
    }

    return page;
  }

  @override
  int get page => _page;

  @override
  int get pageSize => _pageSize;

  @override
  int get totalPage => (_length / _pageSize).ceil();

  @override
  bool get isPaginated => refRows!.hasRange;

  @override
  void setPageSize(int pageSize, {bool notify = true}) {
    _pageSize = pageSize;

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void setPage(int page, {bool notify = true}) {
    _page = page;

    int from = (page - 1) * _pageSize;

    if (from < 0) {
      from = 0;
    }

    int to = page * _pageSize;

    if (to > _length) {
      to = _length;
    }

    _range.setRange(from, to);

    refRows!.setFilterRange(_range);

    clearCurrentCell(notify: false);

    clearCurrentSelecting(notify: false);

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void resetPage({bool notify = true}) {
    setPage(_adjustPage, notify: notify);
  }
}
