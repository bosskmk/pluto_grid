import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoLazyPaginationRequest {
  PlutoLazyPaginationRequest({
    required this.page,
    this.sortColumn,
    this.filterRows = const <PlutoRow>[],
  });

  final int page;

  final PlutoColumn? sortColumn;

  final List<PlutoRow> filterRows;
}

class PlutoLazyPaginationResponse {
  PlutoLazyPaginationResponse({
    required this.totalPage,
    required this.rows,
  });

  final int totalPage;

  final List<PlutoRow> rows;
}

typedef PlutoLazyPaginationFetch = Future<PlutoLazyPaginationResponse> Function(
    PlutoLazyPaginationRequest);

class PlutoLazyPagination extends StatefulWidget {
  const PlutoLazyPagination({
    this.initialPage = 1,
    this.initialFetch = true,
    this.fetchWithSorting = true,
    this.fetchWithFiltering = true,
    this.pageSizeToMove,
    required this.fetch,
    required this.stateManager,
    super.key,
  });

  final int initialPage;

  final bool initialFetch;

  final bool fetchWithSorting;

  final bool fetchWithFiltering;

  /// Set the number of moves to the previous or next page button.
  ///
  /// Default is null.
  /// Moves the page as many as the number of page buttons currently displayed.
  ///
  /// If this value is set to 1, the next previous page is moved by one page.
  final int? pageSizeToMove;

  final PlutoLazyPaginationFetch fetch;

  final PlutoGridStateManager stateManager;

  @override
  State<PlutoLazyPagination> createState() => _PlutoLazyPaginationState();
}

class _PlutoLazyPaginationState extends State<PlutoLazyPagination> {
  late final StreamSubscription<PlutoGridEvent> _events;

  int _page = 1;

  int _totalPage = 0;

  bool _isFetching = false;

  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    _page = widget.initialPage;

    if (widget.fetchWithSorting) {
      stateManager.setSortOnlyEvent(true);
    }

    if (widget.fetchWithFiltering) {
      stateManager.setFilterOnlyEvent(true);
    }

    _events = stateManager.eventManager!.listener(_eventListener);

    if (widget.initialFetch) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setPage(widget.initialPage);
      });
    }
  }

  @override
  void dispose() {
    _events.cancel();

    super.dispose();
  }

  void _eventListener(PlutoGridEvent event) {
    if (event is PlutoGridChangeColumnSortEvent ||
        event is PlutoGridSetColumnFilterEvent) {
      setPage(1);
    }
  }

  void setPage(int page) async {
    if (_isFetching) return;

    _isFetching = true;

    stateManager.setShowLoading(true, level: PlutoGridLoadingLevel.rows);

    widget
        .fetch(
      PlutoLazyPaginationRequest(
        page: page,
        sortColumn: stateManager.getSortedColumn,
        filterRows: stateManager.filterRows,
      ),
    )
        .then((data) {
      stateManager.scroll.bodyRowsVertical!.jumpTo(0);

      stateManager.refRows.clearFromOriginal();
      stateManager.insertRows(0, data.rows);

      setState(() {
        _page = page;

        _totalPage = data.totalPage;

        _isFetching = false;
      });

      stateManager.setShowLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _PaginationWidget(
      iconColor: stateManager.style.iconColor,
      disabledIconColor: stateManager.style.disabledIconColor,
      activatedColor: stateManager.style.activatedBorderColor,
      iconSize: stateManager.style.iconSize,
      height: stateManager.footerHeight,
      page: _page,
      totalPage: _totalPage,
      pageSizeToMove: widget.pageSizeToMove,
      setPage: setPage,
    );
  }
}

class _PaginationWidget extends StatefulWidget {
  const _PaginationWidget({
    required this.iconColor,
    required this.disabledIconColor,
    required this.activatedColor,
    required this.iconSize,
    required this.height,
    this.page = 1,
    required this.totalPage,
    this.pageSizeToMove,
    required this.setPage,
  });

  final Color iconColor;

  final Color disabledIconColor;

  final Color activatedColor;

  final double iconSize;

  final double height;

  final int page;

  final int totalPage;

  /// Set the number of moves to the previous or next page button.
  ///
  /// Default is null.
  /// Moves the page as many as the number of page buttons currently displayed.
  ///
  /// If this value is set to 1, the next previous page is moved by one page.
  final int? pageSizeToMove;

  final void Function(int page) setPage;

  @override
  State<_PaginationWidget> createState() => _PaginationWidgetState();
}

class _PaginationWidgetState extends State<_PaginationWidget> {
  double _maxWidth = 0;

  final _iconSplashRadius = PlutoGridSettings.rowHeight / 2;

  bool get _isFirstPage => widget.page < 2;

  bool get _isLastPage => widget.page > widget.totalPage - 1;

  /// maxWidth < 450 : 1
  /// maxWidth >= 450 : 3
  /// maxWidth >= 550 : 5
  /// maxWidth >= 650 : 7
  int get _itemSize {
    final countItemSize = ((_maxWidth - 350) / 100).floor();

    return countItemSize < 0 ? 0 : min(countItemSize, 3);
  }

  int get _startPage {
    final itemSizeGap = _itemSize + 1;

    var start = widget.page - itemSizeGap;

    if (widget.page + _itemSize > widget.totalPage) {
      start -= _itemSize + widget.page - widget.totalPage;
    }

    return start < 0 ? 0 : start;
  }

  int get _endPage {
    final itemSizeGap = _itemSize + 1;

    var end = widget.page + _itemSize;

    if (widget.page - itemSizeGap < 0) {
      end += itemSizeGap - widget.page;
    }

    return end > widget.totalPage ? widget.totalPage : end;
  }

  List<int> get _pageNumbers {
    return List.generate(
      _endPage - _startPage,
      (index) => _startPage + index,
    );
  }

  int get _pageSizeToMove {
    if (widget.pageSizeToMove == null) {
      return 1 + (_itemSize * 2);
    }

    return widget.pageSizeToMove!;
  }

  void _firstPage() {
    _movePage(1);
  }

  void _beforePage() {
    int beforePage = widget.page - _pageSizeToMove;

    if (beforePage < 1) {
      beforePage = 1;
    }

    _movePage(beforePage);
  }

  void _nextPage() {
    int nextPage = widget.page + _pageSizeToMove;

    if (nextPage > widget.totalPage) {
      nextPage = widget.totalPage;
    }

    _movePage(nextPage);
  }

  void _lastPage() {
    _movePage(widget.totalPage);
  }

  void _movePage(int page) {
    widget.setPage(page);
  }

  ButtonStyle _getNumberButtonStyle(bool isCurrentIndex) {
    return TextButton.styleFrom(
      disabledForegroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(5, 0, 0, 10),
      backgroundColor: Colors.transparent,
    );
  }

  TextStyle _getNumberTextStyle(bool isCurrentIndex) {
    return TextStyle(
      fontSize: isCurrentIndex ? widget.iconSize : null,
      color: isCurrentIndex ? widget.activatedColor : widget.iconColor,
    );
  }

  Widget _makeNumberButton(int index) {
    var pageFromIndex = index + 1;

    var isCurrentIndex = widget.page == pageFromIndex;

    return TextButton(
      onPressed: () {
        _movePage(pageFromIndex);
      },
      style: _getNumberButtonStyle(isCurrentIndex),
      child: Text(
        pageFromIndex.toString(),
        style: _getNumberTextStyle(isCurrentIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, size) {
        _maxWidth = size.maxWidth;

        return Container(
          width: size.maxWidth,
          height: widget.height,
          alignment: Alignment.center,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                IconButton(
                  onPressed: _isFirstPage ? null : _firstPage,
                  icon: const Icon(Icons.first_page),
                  color: widget.iconColor,
                  disabledColor: widget.disabledIconColor,
                  splashRadius: _iconSplashRadius,
                  mouseCursor: _isFirstPage
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.click,
                ),
                IconButton(
                  onPressed: _isFirstPage ? null : _beforePage,
                  icon: const Icon(Icons.navigate_before),
                  color: widget.iconColor,
                  disabledColor: widget.disabledIconColor,
                  splashRadius: _iconSplashRadius,
                  mouseCursor: _isFirstPage
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.click,
                ),
                ..._pageNumbers.map(_makeNumberButton).toList(),
                IconButton(
                  onPressed: _isLastPage ? null : _nextPage,
                  icon: const Icon(Icons.navigate_next),
                  color: widget.iconColor,
                  disabledColor: widget.disabledIconColor,
                  splashRadius: _iconSplashRadius,
                  mouseCursor: _isLastPage
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.click,
                ),
                IconButton(
                  onPressed: _isLastPage ? null : _lastPage,
                  icon: const Icon(Icons.last_page),
                  color: widget.iconColor,
                  disabledColor: widget.disabledIconColor,
                  splashRadius: _iconSplashRadius,
                  mouseCursor: _isLastPage
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.click,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
