import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class RowInfinityScrollScreen extends StatefulWidget {
  static const routeName = 'feature/row-infinity-scroll';

  const RowInfinityScrollScreen({Key? key}) : super(key: key);

  @override
  _RowInfinityScrollScreenState createState() =>
      _RowInfinityScrollScreenState();
}

class _RowInfinityScrollScreenState extends State<RowInfinityScrollScreen> {
  late List<PlutoColumn> columns;

  late List<PlutoRow> rows;

  late PlutoGridStateManager stateManager;

  late List<PlutoRow> fakeFetchedRows;

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(
        title: 'column1',
        field: 'column1',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'column2',
        field: 'column2',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'column3',
        field: 'column3',
        type: PlutoColumnType.date(),
      ),
    ];

    // Pass an empty row to the grid initially.
    rows = [];

    // Instead of fetching data from the server,
    // Create a fake row in advance.
    fakeFetchedRows = DummyData.rowsByColumns(length: 100, columns: columns);
  }

  Future<PlutoInfinityScrollRowsResponse> fetch(
    PlutoInfinityScrollRowsRequest request,
  ) async {
    List<PlutoRow> tempList = fakeFetchedRows;

    // If you have a filtering state,
    // you need to implement it so that the user gets data from the server
    // according to the filtering state.
    //
    // request.lastRow is null when the filtering state changes.
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
    // request.lastRow is null when the sort state changes.
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

    // Data needs to be implemented so that the next row
    // to be fetched by the user is fetched from the server according to the value of lastRow.
    //
    // If [request.lastRow] is null, it corresponds to the first page.
    // After that, implement request.lastRow to get the next row from the server.
    //
    // How many are fetched is not a concern in PlutoGrid.
    // The user just needs to bring as many as they can get at one time.
    //
    // To convert data from server to PlutoRow
    // You can convert it using [PlutoRow.fromJson].
    // In the example, PlutoRow is already created, so it is not created separately.
    Iterable<PlutoRow> fetchedRows = tempList.skipWhile(
      (row) => request.lastRow != null && row.key != request.lastRow!.key,
    );
    if (request.lastRow == null) {
      fetchedRows = fetchedRows.take(30);
    } else {
      fetchedRows = fetchedRows.skip(1).take(30);
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // The return value returns the PlutoInfinityScrollRowsResponse class.
    // isLast should be true when there is no more data to load.
    // rows should pass a List<PlutoRow>.
    final bool isLast =
        fetchedRows.isEmpty || tempList.last.key == fetchedRows.last.key;

    if (isLast && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Last Page!')),
      );
    }

    return Future.value(PlutoInfinityScrollRowsResponse(
      isLast: isLast,
      rows: fetchedRows.toList(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Row infinity scroll',
      topTitle: 'Row infinity scroll',
      topContents: const [
        Text(
            'New rows are loaded when scrolling reaches the end or when you can no longer move from the last row with the keyboard arrow keys or the PageDown button.'),
        Text(
            'The example behaves similarly to pre-creating fake rows instead of fetching data from the server and processing them on the server.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/demo/lib/screen/feature/row_infinity_scroll_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
        onLoaded: (PlutoGridOnLoadedEvent event) {
          stateManager = event.stateManager;
          stateManager.setShowColumnFilter(true);
        },
        createFooter: (s) => PlutoInfinityScrollRows(
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
          fetch: fetch,
          stateManager: s,
        ),
      ),
    );
  }
}
