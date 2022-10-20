import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoInfinityScrollRowsRequest {
  PlutoInfinityScrollRowsRequest({
    this.lastRow,
    this.sortColumn,
    this.filterRows = const <PlutoRow>[],
  });

  final PlutoRow? lastRow;

  final PlutoColumn? sortColumn;

  final List<PlutoRow> filterRows;
}

class PlutoInfinityScrollRowsResponse {
  PlutoInfinityScrollRowsResponse({
    required this.isLast,
    required this.rows,
  });

  final bool isLast;

  final List<PlutoRow> rows;
}

typedef PlutoInfinityScrollRowsFetch = Future<PlutoInfinityScrollRowsResponse>
    Function(PlutoInfinityScrollRowsRequest);

class PlutoInfinityScrollRows extends StatefulWidget {
  const PlutoInfinityScrollRows({
    this.initialFetch = true,
    this.fetchWithSorting = true,
    this.fetchWithFiltering = true,
    required this.fetch,
    required this.stateManager,
    super.key,
  });

  final bool initialFetch;

  final bool fetchWithSorting;

  final bool fetchWithFiltering;

  final PlutoInfinityScrollRowsFetch fetch;

  final PlutoGridStateManager stateManager;

  @override
  State<PlutoInfinityScrollRows> createState() =>
      _PlutoInfinityScrollRowsState();
}

class _PlutoInfinityScrollRowsState extends State<PlutoInfinityScrollRows> {
  late final StreamSubscription<PlutoGridEvent> _events;

  bool _isFetching = false;

  bool _isLast = false;

  PlutoGridStateManager get stateManager => widget.stateManager;

  ScrollController get scroll => stateManager.scroll.bodyRowsVertical!;

  @override
  void initState() {
    super.initState();

    if (widget.fetchWithSorting) {
      stateManager.setSortOnlyEvent(true);
    }

    if (widget.fetchWithFiltering) {
      stateManager.setFilterOnlyEvent(true);
    }

    _events = stateManager.eventManager!.listener(_eventListener);

    scroll.addListener(_scrollListener);

    if (widget.initialFetch) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _update(null);
      });
    }
  }

  @override
  void dispose() {
    scroll.removeListener(_scrollListener);

    _events.cancel();

    super.dispose();
  }

  void _eventListener(PlutoGridEvent event) {
    if (event is PlutoGridCannotMoveCurrentCellEvent &&
        event.direction.isDown &&
        !_isFetching) {
      _update(stateManager.refRows.last);
    } else if (event is PlutoGridChangeColumnSortEvent) {
      _update(null);
    } else if (event is PlutoGridSetColumnFilterEvent) {
      _update(null);
    }
  }

  void _scrollListener() {
    if (scroll.offset == scroll.position.maxScrollExtent && !_isFetching) {
      _update(stateManager.refRows.last);
    }
  }

  void _update(PlutoRow? lastRow) {
    if (lastRow == null) _isLast = false;

    if (_isLast) return;

    _isFetching = true;

    stateManager.setShowLoading(true, level: PlutoGridLoadingLevel.rows);

    final request = PlutoInfinityScrollRowsRequest(
      lastRow: lastRow,
      sortColumn: stateManager.getSortedColumn,
      filterRows: stateManager.filterRows,
    );

    widget.fetch(request).then((response) {
      if (lastRow == null) {
        scroll.jumpTo(0);
        stateManager.removeAllRows(notify: false);
      }

      stateManager.appendRows(response.rows);

      stateManager.setShowLoading(false);

      _isFetching = false;

      _isLast = response.isLast;
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
