import 'package:example/TextAdaptiveRow.dart';
import 'package:example/mock_rows.dart';
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
  double calculateTextHeight({
    required String text,
    required double maxWidth,
    required TextStyle style,
  }) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: null,
        textDirection: TextDirection.ltr,
        textWidthBasis: TextWidthBasis.longestLine)
      ..layout(maxWidth: maxWidth);

    return textPainter.size.height + 30;
  }

  final List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      enableEditingMode: false,
      title: 'Question',
      field: 'question',
      type: PlutoColumnType.text(),
      renderer: (rendererContext) {
        final cellValue = rendererContext.cell.value as String;

        final hasError = cellValue.contains('error'); // Just an example
        final imageUrl =
            'https://example.com/image.png'; // Replace with your logic

        return Row(
          children: [
            Expanded(
              child: Text(
                cellValue,
                style: TextStyle(
                  color: hasError ? Colors.red : Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Image.network(
              imageUrl,
              width: 20,
              height: 20,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 20),
            ),
            if (hasError) ...[
              const SizedBox(width: 4),
              const Icon(Icons.error, color: Colors.red, size: 20),
            ],
          ],
        );
      },
    ),
    PlutoColumn(
        width: 230,
        enableEditingMode: false,
        title: "Test",
        field: "test",
        type: PlutoColumnType.text(),
        renderer: (context) {
          final cellValue = context.cell.value?.toString() ?? '';
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              cellValue,
              style: TextStyle(fontSize: 14),
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
          ],
        );
      },
    ),

    PlutoColumn(
        title: 'Name',
        field: 'name',
        type: PlutoColumnType.text(),
        enableContextMenu: false),
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

  final List<PlutoRow> rows = [];

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
  void initState() {
    const cellPadding = 16.0; // top + bottom padding
    const double defaultWidth = 200.0; // Approximate column width
    const TextStyle textStyle =
        TextStyle(fontSize: 14); // Match your grid style

    for (var row in mockRows) {
      // Calculate height for each wrapped field
      final double testHeight = calculateTextHeight(
          text: row.test, style: textStyle, maxWidth: defaultWidth);
      final double nameHeight = calculateTextHeight(
          text: row.name, style: textStyle, maxWidth: defaultWidth);
      final double roleHeight = calculateTextHeight(
          text: row.role, style: textStyle, maxWidth: defaultWidth);

      // Final row height is the max of wrapped content + padding
      // final double customHeight = [
      //       testHeight,
      //       nameHeight,
      //       roleHeight,
      //     ].reduce((a, b) => a > b ? a : b) +
      //     cellPaddin

      rows.add(PlutoRow(
        cells: {
          'question': PlutoCell(
            value: row.question,
          ),
          'test': PlutoCell(value: row.test),
          'id': PlutoCell(value: row.id),
          'name': PlutoCell(value: row.name),
          'age': PlutoCell(value: row.age),
          'role': PlutoCell(value: row.role),
          'joined': PlutoCell(value: row.joined),
          'working_time': PlutoCell(value: row.workingTime),
          'salary': PlutoCell(value: row.salary),
        },
        customRowHeight: testHeight,
      ));
    }
    super.initState();
  }

  final Set<String> hiddenRowIds = {}; // IDs of hidden rows
  void applyCustomFilter() {
    stateManager.setFilter(null); // clear previous filters

    stateManager.setFilter((PlutoRow row) {
      final rowId = row.cells['id']?.value.toString();
      return !hiddenRowIds.contains(rowId); // hide if in hidden set
    });

    stateManager.notifyListeners(); // update UI
  }

  void hideRowById(String id) {
    hiddenRowIds.add(id);
    applyCustomFilter();
  }

  void showRowById(String id) {
    hiddenRowIds.remove(id);
    applyCustomFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pluto Grid Example'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () => hideRowById("U1001"),
                child: Text('Hide Row U1001'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => showRowById("U1001"),
                child: Text('Show Row U1001'),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(15),
              child: PlutoGrid(
                columns: columns,
                rows: rows,
                columnGroups: columnGroups,
                onLoaded: (PlutoGridOnLoadedEvent event) {
                  stateManager = event.stateManager;
                  stateManager.setShowColumnFilter(false);
                },
                onChanged: (PlutoGridOnChangedEvent event) {
                  print(event);
                },
                configuration: PlutoGridConfiguration(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class NoColumnMenuDelegate extends PlutoColumnMenuDelegate {
//   @override
//   void showColumnMenu({
//     required BuildContext context,
//     required PlutoGridStateManager stateManager,
//     required PlutoColumn column,
//     required Offset offset,
//   }) {
//     // Do nothing to fully disable the menu
//   }

//   @override
//   List<PopupMenuEntry<dynamic>> buildMenuItems({
//     required PlutoColumn column,
//     required PlutoGridStateManager stateManager,
//   }) {
//     // Return an empty list to disable menu items
//     return [];
//   }

//   @override
//   void onSelected({
//     required PlutoColumn column,
//     required BuildContext context,
//     required bool mounted,
//     required dynamic selected,
//     required PlutoGridStateManager stateManager,
//   }) {
//     // Do nothing
//   }
// }
