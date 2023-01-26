import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class RowLazyPaginationScreen extends StatefulWidget {
  static const routeName = 'feature/row-lazy-pagination';

  const RowLazyPaginationScreen({Key? key}) : super(key: key);

  @override
  State<RowLazyPaginationScreen> createState() =>
      _RowLazyPaginationScreenState();
}

class _RowLazyPaginationScreenState extends State<RowLazyPaginationScreen> {
  late final PlutoGridStateManager stateManager;

  final List<PlutoColumn> columns = [];

  // Pass an empty row to the grid initially.
  final List<PlutoRow> rows = [];

  final List<PlutoRow> fakeFetchedRows = [];

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 1000);

    columns.addAll(dummyData.columns);

    // Instead of fetching data from the server,
    // Create a fake row in advance.
    fakeFetchedRows.addAll(dummyData.rows);
  }

  Future<PlutoLazyPaginationResponse> fetch(
    PlutoLazyPaginationRequest request,
  ) async {
    List<PlutoRow> tempList = fakeFetchedRows;

    // If you have a filtering state,
    // you need to implement it so that the user gets data from the server
    // according to the filtering state.
    //
    // request.page is 1 when the filtering state changes.
    // This is because, when the filtering state is changed,
    // the first page must be loaded with the new filtering applied.
    //
    // request.filterRows is a List<PlutoRow> type containing filtering information.
    // To convert to Map type, you can do as follows.
    //
    // FilterHelper.convertRowsToMap(request.filterRows);
    //
    // When the filter of abc is applied as Contains type to column2
    // and 123 as Contains type to column3, for example
    // It is returned as below.
    // {column2: [{Contains: 123}], column3: [{Contains: abc}]}
    //
    // If multiple filtering conditions are set in one column,
    // multiple conditions are included as shown below.
    // {column2: [{Contains: abc}, {Contains: 123}]}
    //
    // The filter type in FilterHelper.defaultFilters is the default,
    // If there is user-defined filtering,
    // the title set by the user is returned as the filtering type.
    // All filtering can change the value returned as a filtering type by changing the name property.
    // In case of PlutoFilterTypeContains filter, if you change the static type name to include
    // PlutoFilterTypeContains.name = 'include';
    // {column2: [{include: abc}, {include: 123}]} will be returned.
    if (request.filterRows.isNotEmpty) {
      final filter = FilterHelper.convertRowsToFilter(
        request.filterRows,
        stateManager.refColumns,
      );

      tempList = fakeFetchedRows.where(filter!).toList();
    }

    // If there is a sort state,
    // you need to implement it so that the user gets data from the server
    // according to the sort state.
    //
    // request.page is 1 when the sort state changes.
    // This is because when the sort state changes,
    // new data to which the sort state is applied must be loaded.
    if (request.sortColumn != null && !request.sortColumn!.sort.isNone) {
      tempList = [...tempList];

      tempList.sort((a, b) {
        final sortA = request.sortColumn!.sort.isAscending ? a : b;
        final sortB = request.sortColumn!.sort.isAscending ? b : a;

        return request.sortColumn!.type.compare(
          sortA.cells[request.sortColumn!.field]!.valueForSorting,
          sortB.cells[request.sortColumn!.field]!.valueForSorting,
        );
      });
    }

    final page = request.page;
    const pageSize = 100;
    final totalPage = (tempList.length / pageSize).ceil();
    final start = (page - 1) * pageSize;
    final end = start + pageSize;

    Iterable<PlutoRow> fetchedRows = tempList.getRange(
      max(0, start),
      min(tempList.length, end),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    return Future.value(PlutoLazyPaginationResponse(
      totalPage: totalPage,
      rows: fetchedRows.toList(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Row lazy pagination',
      topTitle: 'Row lazy pagination',
      topContents: const [
        Text(
            'Implement pagination in the form of fetching data from the server.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/demo/lib/screen/feature/row_lazy_pagination_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onLoaded: (PlutoGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setShowColumnFilter(true);
        },
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
        configuration: const PlutoGridConfiguration(),
        createFooter: (stateManager) {
          return PlutoLazyPagination(
            // Determine the first page.
            // Default is 1.
            initialPage: 1,

            // First call the fetch function to determine whether to load the page.
            // Default is true.
            initialFetch: true,

            // Decide whether sorting will be handled by the server.
            // If false, handle sorting on the client side.
            // Default is true.
            fetchWithSorting: true,

            // Decide whether filtering is handled by the server.
            // If false, handle filtering on the client side.
            // Default is true.
            fetchWithFiltering: true,

            // Determines the page size to move to the previous and next page buttons.
            // Default value is null. In this case,
            // it moves as many as the number of page buttons visible on the screen.
            pageSizeToMove: null,
            fetch: fetch,
            stateManager: stateManager,
          );
        },
      ),
    );
  }
}
