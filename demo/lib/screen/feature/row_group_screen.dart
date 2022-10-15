import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_docs_button.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class RowGroupScreen extends StatefulWidget {
  static const routeName = 'feature/row-group';

  const RowGroupScreen({Key? key}) : super(key: key);

  @override
  _RowGroupScreenState createState() => _RowGroupScreenState();
}

class _RowGroupScreenState extends State<RowGroupScreen> {
  final List<PlutoColumn> columnsA = [];

  final List<PlutoRow> rowsA = [];

  final List<PlutoColumn> columnsB = [];

  final List<PlutoRow> rowsB = [];

  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columnsA.addAll([
      PlutoColumn(
        title: 'Planets',
        field: 'planets',
        type: PlutoColumnType.select([
          'Mercury',
          'Venus',
          'Earth',
          'Mars',
          'Jupiter',
          'Saturn',
          'Uranus',
          'Neptune',
          'Pluto',
        ]),
      ),
      PlutoColumn(title: 'Users', field: 'users', type: PlutoColumnType.text()),
      PlutoColumn(title: 'Date', field: 'date', type: PlutoColumnType.date()),
      PlutoColumn(title: 'Time', field: 'time', type: PlutoColumnType.time()),
    ]);

    rowsA.addAll(DummyData.rowsByColumns(length: 100, columns: columnsA));

    columnsB.addAll([
      PlutoColumn(
        title: 'Files',
        field: 'files',
        type: PlutoColumnType.text(),
        renderer: (c) {
          IconData icon =
              c.row.type.isGroup ? Icons.folder : Icons.file_present;
          return Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 10),
              Text(c.cell.value),
            ],
          );
        },
      ),
    ]);

    rowsB.addAll([
      PlutoRow(
        cells: {'files': PlutoCell(value: 'PlutoGrid')},
        type: PlutoRowType.group(
            children: FilteredList<PlutoRow>(
          initialList: [
            PlutoRow(
              cells: {'files': PlutoCell(value: 'lib')},
              type: PlutoRowType.group(
                children: FilteredList<PlutoRow>(
                  initialList: [
                    PlutoRow(
                      cells: {'files': PlutoCell(value: 'src')},
                      type: PlutoRowType.group(
                          children: FilteredList<PlutoRow>(
                        initialList: [
                          PlutoRow(cells: {
                            'files': PlutoCell(value: 'pluto_grid.dart')
                          }),
                          PlutoRow(cells: {
                            'files': PlutoCell(value: 'pluto_dual_grid.dart')
                          }),
                        ],
                      )),
                    ),
                  ],
                ),
              ),
            ),
            PlutoRow(
              cells: {'files': PlutoCell(value: 'test')},
              type: PlutoRowType.group(
                children: FilteredList<PlutoRow>(
                  initialList: [
                    PlutoRow(
                      cells: {
                        'files': PlutoCell(value: 'pluto_grid_test.dart')
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        )),
      ),
      PlutoRow(
        cells: {'files': PlutoCell(value: 'PlutoMenuBar')},
        type: PlutoRowType.group(
            children: FilteredList<PlutoRow>(
          initialList: [
            PlutoRow(
              cells: {'files': PlutoCell(value: 'pluto_menu_bar.dart')},
            ),
          ],
        )),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Row group',
      topTitle: 'Row group',
      topContents: const [
        Text('Grouping rows in a column or tree structure.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/demo/lib/screen/feature/row_group_screen.dart',
        ),
        PlutoDocsButton(url: 'https://pluto.weblaze.dev/row-grouping'),
      ],
      body: PlutoDualGrid(
        gridPropsA: PlutoDualGridProps(
          columns: columnsA,
          rows: rowsA,
          configuration: const PlutoGridConfiguration(
            style: PlutoGridStyleConfig(
              cellColorGroupedRow: Color(0x80F6F6F6),
            ),
          ),
          onLoaded: (e) => e.stateManager.setRowGroup(
            PlutoRowGroupByColumnDelegate(
              columns: [
                columnsA[0],
                columnsA[1],
              ],
              showFirstExpandableIcon: false,
            ),
          ),
        ),
        gridPropsB: PlutoDualGridProps(
          columns: columnsB,
          rows: rowsB,
          configuration: const PlutoGridConfiguration(
            style: PlutoGridStyleConfig(
              cellColorGroupedRow: Color(0x80F6F6F6),
            ),
            columnSize: PlutoGridColumnSizeConfig(
              autoSizeMode: PlutoAutoSizeMode.equal,
            ),
          ),
          onLoaded: (e) {
            e.stateManager.setRowGroup(PlutoRowGroupTreeDelegate(
              resolveColumnDepth: (column) =>
                  e.stateManager.columnIndex(column),
              showText: (cell) => true,
              showFirstExpandableIcon: true,
            ));
          },
        ),
      ),
    );
  }
}
