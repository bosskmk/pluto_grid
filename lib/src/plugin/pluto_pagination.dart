import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoPagination extends PlutoStatefulWidget {
  const PlutoPagination(this.stateManager, {Key? key}) : super(key: key);

  @override
  final PlutoGridStateManager stateManager;

  @override
  _PlutoPaginationState createState() => _PlutoPaginationState();
}

abstract class _PlutoPaginationStateWithChange
    extends PlutoStateWithChange<PlutoPagination> {
  int page = 1;

  int totalPage = 1;

  @override
  void initState() {
    super.initState();

    page = widget.stateManager.page;

    totalPage = widget.stateManager.totalPage;

    widget.stateManager.setPage(page, notify: false);
  }

  @override
  void onChange() {
    resetState((update) {
      page = update<int>(
        page,
        widget.stateManager.page,
      );

      totalPage = update<int>(
        totalPage,
        widget.stateManager.totalPage,
      );
    });
  }
}

class _PlutoPaginationState extends _PlutoPaginationStateWithChange {
  late double _maxWidth;

  final _iconSplashRadius = PlutoGridSettings.rowHeight / 2;

  bool get _isFirstPage => page < 2;

  bool get _isLastPage => page > totalPage - 1;

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

    var start = page - itemSizeGap;

    if (page + _itemSize > totalPage) {
      start -= _itemSize + page - totalPage;
    }

    return start < 0 ? 0 : start;
  }

  int get _endPage {
    final itemSizeGap = _itemSize + 1;

    var end = page + _itemSize;

    if (page - itemSizeGap < 0) {
      end += itemSizeGap - page;
    }

    return end > totalPage ? totalPage : end;
  }

  List<int> get _pageNumbers {
    return List.generate(
      _endPage - _startPage,
      (index) => _startPage + index,
    );
  }

  void _firstPage() {
    _movePage(1);
  }

  void _beforePage() {
    setState(() {
      page -= 1 + (_itemSize * 2);

      if (page < 1) {
        page = 1;
      }

      _movePage(page);
    });
  }

  void _nextPage() {
    setState(() {
      page += 1 + (_itemSize * 2);

      if (page > totalPage) {
        page = totalPage;
      }

      _movePage(page);
    });
  }

  void _lastPage() {
    _movePage(totalPage);
  }

  void _movePage(int page) {
    widget.stateManager.setPage(page);
  }

  ButtonStyle _getNumberButtonStyle(bool isCurrentIndex) {
    return TextButton.styleFrom(
      primary: Colors.transparent,
      onSurface: Colors.transparent,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(5, 0, 0, 10),
      backgroundColor: Colors.transparent,
    );
  }

  TextStyle _getNumberTextStyle(bool isCurrentIndex) {
    return TextStyle(
      fontSize:
          isCurrentIndex ? widget.stateManager.configuration!.iconSize : null,
      color: isCurrentIndex
          ? widget.stateManager.configuration!.activatedBorderColor
          : widget.stateManager.configuration!.iconColor,
    );
  }

  Widget _makeNumberButton(int index) {
    var pageFromIndex = index + 1;

    var isCurrentIndex = page == pageFromIndex;

    return TextButton(
      onPressed: () {
        widget.stateManager.setPage(pageFromIndex);
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
      builder: (layoutContext, size) {
        _maxWidth = size.maxWidth;
        final Color _iconColor = widget.stateManager.configuration!.iconColor;
        final Color _disabledIconColor =
            widget.stateManager.configuration!.disabledIconColor;
        // can't center using center, it'll take all max width and max height
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _isFirstPage ? null : _firstPage,
                      icon: const Icon(Icons.first_page),
                      color: _iconColor,
                      disabledColor: _disabledIconColor,
                      splashRadius: _iconSplashRadius,
                      mouseCursor: _isFirstPage
                          ? SystemMouseCursors.basic
                          : SystemMouseCursors.click,
                    ),
                    IconButton(
                      onPressed: _isFirstPage ? null : _beforePage,
                      icon: const Icon(Icons.navigate_before),
                      color: _iconColor,
                      disabledColor: _disabledIconColor,
                      splashRadius: _iconSplashRadius,
                      mouseCursor: _isFirstPage
                          ? SystemMouseCursors.basic
                          : SystemMouseCursors.click,
                    ),
                    ..._pageNumbers.map(_makeNumberButton).toList(),
                    IconButton(
                      onPressed: _isLastPage ? null : _nextPage,
                      icon: const Icon(Icons.navigate_next),
                      color: _iconColor,
                      disabledColor: _disabledIconColor,
                      splashRadius: _iconSplashRadius,
                      mouseCursor: _isLastPage
                          ? SystemMouseCursors.basic
                          : SystemMouseCursors.click,
                    ),
                    IconButton(
                      onPressed: _isLastPage ? null : _lastPage,
                      icon: const Icon(Icons.last_page),
                      color: _iconColor,
                      disabledColor: _disabledIconColor,
                      splashRadius: _iconSplashRadius,
                      mouseCursor: _isLastPage
                          ? SystemMouseCursors.basic
                          : SystemMouseCursors.click,
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
