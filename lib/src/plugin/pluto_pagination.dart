import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoPagination extends PlutoStatefulWidget {
  PlutoPagination(this.stateManager, {Key? key}) : super(key: key);

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
  int get _startPaging {
    var start = page - 4;

    if (page + 3 > totalPage) {
      start -= 3 + page - totalPage;
    }

    return start < 0 ? 0 : start;
  }

  int get _endPaging {
    var end = page + 3;

    if (page - 4 < 0) {
      end += 4 - page;
    }

    return end > totalPage ? totalPage : end;
  }

  void _firstPage() {
    _movePage(1);
  }

  void _beforePage() {
    setState(() {
      page -= 1;

      if (page < 1) {
        page = 1;
      }

      _movePage(page);
    });
  }

  void _nextPage() {
    setState(() {
      page += 1;

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

  final _iconButtonStyle = ElevatedButton.styleFrom(
    primary: Colors.transparent,
    onPrimary: Colors.transparent,
    onSurface: Colors.transparent,
    shadowColor: Colors.transparent,
  );

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
          : widget.stateManager.configuration!.gridBorderColor,
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
    final Color _iconColor = widget.stateManager.configuration!.gridBorderColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: _firstPage,
              child: Icon(
                Icons.first_page,
                color: _iconColor,
              ),
              style: _iconButtonStyle,
            ),
            ElevatedButton(
              onPressed: _beforePage,
              child: Icon(
                Icons.navigate_before,
                color: _iconColor,
              ),
              style: _iconButtonStyle,
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...List.generate(
                        totalPage,
                        _makeNumberButton,
                      ).getRange(_startPaging, _endPaging),
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _nextPage,
              child: Icon(
                Icons.navigate_next,
                color: _iconColor,
              ),
              style: _iconButtonStyle,
            ),
            ElevatedButton(
              onPressed: _lastPage,
              child: Icon(
                Icons.last_page,
                color: _iconColor,
              ),
              style: _iconButtonStyle,
            ),
          ],
        ),
      ),
    );
  }
}
