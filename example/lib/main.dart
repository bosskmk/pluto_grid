import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlutoGrid Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PlutoGridExamplePage(),
    );
  }
}

/// PlutoGrid Example
//
/// For more examples, go to the demo web link on the github below.
class PlutoGridExamplePage extends StatefulWidget {
  const PlutoGridExamplePage({Key? key}) : super(key: key);

  @override
  State<PlutoGridExamplePage> createState() => _PlutoGridExamplePageState();
}

class _PlutoGridExamplePageState extends State<PlutoGridExamplePage> {
  final List<PlutoColumn> columns = <PlutoColumn>[
    // PlutoColumn(
    //   title: 'Id',
    //   field: 'id',
    //   type: PlutoColumnType.text(),
    // ),
    PlutoColumn(
        title: "Test",
        field: "test",
        type: PlutoColumnType.text(),
        renderer: (context) {
          final cellValue = context.cell.value?.toString() ?? '';
          return Container(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              cellValue,
              softWrap: true,
              overflow: TextOverflow.clip,
            ),
          );
        }),
    PlutoColumn(
      title: 'Id',
      field: 'id',
      type: PlutoColumnType.text(),
      renderer: (PlutoColumnRendererContext context) {
        return Row(
          children: [
            Icon(Icons.edit, size: 16, color: Colors.grey),
            SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 200,
                child: TextField(
                  controller: TextEditingController(
                    text:
                        "context.cell.value?.toString() ?? ''maa mamamama amamama ama ma ma m am m am am ajedjmn ailk. askjfbakf kaskdajskfbakjf akjsbd aksd a kasdasda  ",
                  ),
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 50, horizontal: 10),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    context.stateManager.changeCellValue(context.cell, value);
                  },
                ),
              ),
            ),
          ],
        );
      },
    ),

    PlutoColumn(
      title: 'Name',
      field: 'name',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Age age ',
      field: 'age',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: 'Role',
      field: 'role',
      type: PlutoColumnType.select(<String>[
        'Programmer ',
        'Designer',
        'Owner',
      ]),
    ),
    PlutoColumn(
      title: 'Joined',
      field: 'joined',
      type: PlutoColumnType.date(),
    ),
    PlutoColumn(
      title: 'Working time',
      field: 'working_time',
      type: PlutoColumnType.time(),
    ),
    // PlutoColumn(
    //   title: 'salary',
    //   field: 'salary',
    //   type: PlutoColumnType.currency(),
    //   footerRenderer: (rendererContext) {
    //     return PlutoAggregateColumnFooter(
    //       rendererContext: rendererContext,
    //       formatAsCurrency: true,
    //       type: PlutoAggregateColumnType.sum,
    //       format: '#,###',
    //       alignment: Alignment.center,
    //       titleSpanBuilder: (text) {
    //         return [
    //           const TextSpan(
    //             text: 'Sum',
    //             style: TextStyle(color: Colors.red),
    //           ),
    //           const TextSpan(text: ' : '),
    //           TextSpan(text: text),
    //         ];
    //       },
    //     );
    //   },
    // ),
    PlutoColumn(
      title: 'salary',
      field: 'salary',
      type: PlutoColumnType.text(),
      renderer: (PlutoColumnRendererContext context) {
        List<String> items = ['Apple', 'Banana', 'Cherry', 'Date', 'Mango'];

        return DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: Text('Select Fruit'),
            value: items.contains(context.cell.value?.toString())
                ? context.cell.value.toString()
                : null,
            items: items
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
            onChanged: (value) {
              context.stateManager.changeCellValue(context.cell, value);
            },
            dropdownSearchData: DropdownSearchData(
              searchController: TextEditingController(),
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                return (item.value ?? '')
                    .toLowerCase()
                    .contains((searchValue ?? '').toLowerCase());
              },
            ),
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
            dropdownStyleData: const DropdownStyleData(
              maxHeight: 400,
            ),
          ),
        );
      },
    ),
  ];

  final List<PlutoRow> rows = [
    PlutoRow(cells: {
      'test': PlutoCell(
          value:
              " tetsststststststststs tsttstststs. tsttsttststs kxcbjttwtwt wywwwwy"),
      'id': PlutoCell(
          value:
              'user1user1us. er1user1user1user.  1user1user1user1user1. user1user1user1user1user1user1user1user1user1user1user1user1user1 '),
      'name': PlutoCell(
          value:
              'MikeMi. keMikeMikeMik.  eMikeMikeMik. eMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMike'),
      'age': PlutoCell(value: 20),
      'role': PlutoCell(value: 'Programmer'),
      'joined': PlutoCell(value: '2021-01-01'),
      'working_time': PlutoCell(value: '09:00'),
      'salary': PlutoCell(value: 300),
    }, customRowHeight: 100),
    PlutoRow(
      cells: {
        'test': PlutoCell(
            value:
                " tetsststststststststs tsttstststs. tsttsttststs kxcbjttwtwt wywwwwy"),
        'id': PlutoCell(value: 'user2'),
        'name': PlutoCell(
            value:
                'MikeMik.   eMikeMikeMikeMikeMi.  keMikeMikeMikeMike MikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMikeMike'),
        'age': PlutoCell(value: 25),
        'role': PlutoCell(value: 'Designer'),
        'joined': PlutoCell(value: '2021-02-01'),
        'working_time': PlutoCell(value: '10:00'),
        'salary': PlutoCell(value: 400),
      },
    ),
    PlutoRow(cells: {
      'test': PlutoCell(
          value:
              " tetsststststststststs tsttstststs. tsttsttststs kxcbjttwtwt wywwwwy"),
      'id': PlutoCell(value: ''),
      'name': PlutoCell(value: ''),
      'age': PlutoCell(value: 0),
      'role': PlutoCell(value: ''),
      'joined': PlutoCell(value: ''),
      'working_time': PlutoCell(value: ''),
      'salary': PlutoCell(value: 0),
    }, customRowHeight: 200),
  ];

  /// columnGroups that can group columns can be omitted.
  final List<PlutoColumnGroup> columnGroups = [
    PlutoColumnGroup(title: 'Id', fields: ['id'], expandedColumn: true),
    PlutoColumnGroup(title: 'User information', fields: ['name', 'age']),
    PlutoColumnGroup(title: 'Status', children: [
      PlutoColumnGroup(title: 'A', fields: ['role'], expandedColumn: true),
      PlutoColumnGroup(title: 'Etc.', fields: ['joined', 'working_time']),
    ]),
  ];

  /// [PlutoGridStateManager] has many methods and properties to dynamically manipulate the grid.
  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  late final PlutoGridStateManager stateManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          columnGroups: columnGroups,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
            stateManager.setShowColumnFilter(true);
          },
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          configuration: const PlutoGridConfiguration(),
        ),
      ),
    );
  }
}
