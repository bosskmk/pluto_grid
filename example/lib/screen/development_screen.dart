import 'package:example/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../dummy_data/development.dart';

class DevelopmentScreen extends StatefulWidget {
  static const routeName = 'development';

  @override
  _DevelopmentScreenState createState() => _DevelopmentScreenState();
}

class _DevelopmentScreenState extends State<DevelopmentScreen> {
  List<PlutoColumn>? columns;

  List<PlutoRow>? rows;

  PlutoGridStateManager? stateManager;

  PlutoGridSelectingMode? gridSelectingMode = PlutoGridSelectingMode.row;

  List<bool> hideGroups = [false, false, false];

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(
        title: 'column1',
        field: 'column1',
        type: PlutoColumnType.text(),
        enableRowDrag: true,
        enableRowChecked: true,
        enableContextMenu: false,
        enableDropToResize: true,
        width: 250,
        minWidth: 175,
        renderer: (rendererContext) {
          return Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                ),
                onPressed: () {
                  rendererContext.stateManager!.insertRows(
                    rendererContext.rowIdx!,
                    rendererContext.stateManager!.getNewRows(count: 3),
                  );
                },
                iconSize: 18,
                color: Colors.green,
                padding: const EdgeInsets.all(0),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outlined,
                ),
                onPressed: () {
                  rendererContext.stateManager!.removeRows([rendererContext.row]);
                },
                iconSize: 18,
                color: Colors.red,
                padding: const EdgeInsets.all(0),
              ),
              Expanded(
                child: Text(
                  '${rendererContext.row!.sortIdx.toString()}(${rendererContext.row!.cells[rendererContext.column!.field]!.value.toString()})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
      PlutoColumn(
        title: 'column2',
        field: 'column2',
        enableContextMenu: false,
        type: PlutoColumnType.select(<String>['red', 'blue', 'green']),
        renderer: (rendererContext) {
          Color textColor = Colors.black;

          if (rendererContext.cell!.value == 'red') {
            textColor = Colors.red;
          } else if (rendererContext.cell!.value == 'blue') {
            textColor = Colors.blue;
          } else if (rendererContext.cell!.value == 'green') {
            textColor = Colors.green;
          }

          return Text(
            rendererContext.cell!.value.toString(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'column3',
        field: 'column3',
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: 'column4',
        field: 'column4',
        type: PlutoColumnType.time(),
      ),
      PlutoColumn(
        title: 'column5',
        field: 'column5',
        type: PlutoColumnType.number(
          negative: true,
        ),
      ),
      PlutoColumn(
        title: 'column6',
        field: 'column6',
        type: PlutoColumnType.text(),
        enableFilterMenuItem: false,
        enableEditingMode: false,
        renderer: (rendererContext) {
          return Image.asset('assets/images/cat.jpg');
        },
      ),
    ];

    rows = DummyData.rowsByColumns(length: 100, columns: columns);
  }

  void handleAddRowButton({int? count}) {
    final List<PlutoRow> rows = count == null
        ? [DummyData.rowByColumns(columns!)]
        : DummyData.rowsByColumns(length: count, columns: columns);

    stateManager!.prependRows(rows);
  }

  void handleRemoveCurrentRowButton() {
    stateManager!.removeCurrentRow();
  }

  void handleRemoveSelectedRowsButton() {
    stateManager!.removeRows(stateManager!.currentSelectingRows);
  }

  void handleToggleColumnFilter() {
    stateManager!.setShowColumnFilter(!stateManager!.showColumnFilter);
  }

  void handleOnRowChecked(PlutoGridOnRowCheckedEvent event) {
    if (event.isRow) {
      print('Toggled A Row.');
      print(event.row?.cells['column1']?.value);
    } else {
      print('Toggled All Rows.');
      print(stateManager?.checkedRows.length);
    }
  }

  void setGridSelectingMode(PlutoGridSelectingMode? mode) {
    if (gridSelectingMode == mode) {
      return;
    }

    setState(() {
      gridSelectingMode = mode;
      stateManager!.setSelectingMode(mode!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: PlutoGrid(
          
          columnGroups: [
            PlutoColumnGroup(
              columns: columns!.sublist(0, 2),
              title: const Align(
                child: Text('test 1'),
              ),
            ),
            PlutoColumnGroup(
              columns: columns!.sublist(2, 4),
              title: const Align(
                child: Text('test 2'),
              ),
            ),
            PlutoColumnGroup(
              columns: columns!.sublist(4, 6),
              title: const Align(
                child: Text('test 3'),
              ),
            ),
          ],
          // columns: columns,
          rows: rows,
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
            stateManager!.setSelectingMode(gridSelectingMode!);
            stateManager!.setShowColumnFilter(true);
          },
          onRowChecked: handleOnRowChecked,
          // onRowDoubleTap: (e) {
          //   print('Double click A Row.');
          //   print(e.row?.cells['column1']?.value);
          // },
          // onRowSecondaryTap: (e) {
          //   print('Secondary click A Row.(${e.offset})');
          //   print(e.row?.cells['column1']?.value);
          // },
          

          createHeader: (PlutoGridStateManager stateManager) {
            // print(stateManager.refColumnGroups);
            print('rebuild');
            
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                height: stateManager.headerHeight,
                child: Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    
                    ElevatedButton(
                      child: const Text('hide group 1'),
                      onPressed: () {
                        final colGroup = stateManager.refColumnGroups![0];
                        stateManager.hideColumnGroup(colGroup.key, !colGroup.hide, notify: true);
                        setState(() {});
                      },
                    ),
                    ElevatedButton(
                      child: const Text('hide group 2'),
                      onPressed: () {
                        final colGroup = stateManager.refColumnGroups![1];
                        stateManager.hideColumnGroup(colGroup.key, !colGroup.hide, notify: true);
                        setState(() {});
                      },
                    ),
                    ElevatedButton(
                      child: const Text('hide group 3'),
                      onPressed: () {
                        final colGroup = stateManager.refColumnGroups![2];
                        stateManager.hideColumnGroup(colGroup.key, !colGroup.hide, notify: true);
                        // setState(() {});
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Go Home'),
                      onPressed: () {
                        Navigator.pushNamed(context, HomeScreen.routeName);
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Add 10'),
                      onPressed: () {
                        handleAddRowButton(count: 10);
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Add 100 Rows'),
                      onPressed: () => handleAddRowButton(count: 100),
                    ),
                    ElevatedButton(
                      child: const Text('Add 100,000 Rows'),
                      onPressed: () => handleAddRowButton(count: 100000),
                    ),
                    ElevatedButton(
                      child: const Text('Remove Current Row'),
                      onPressed: handleRemoveCurrentRowButton,
                    ),
                    ElevatedButton(
                      child: const Text('Remove Selected Rows'),
                      onPressed: handleRemoveSelectedRowsButton,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: gridSelectingMode,
                        items: PlutoGridStateManager.selectingModes
                            .map<DropdownMenuItem<PlutoGridSelectingMode>>(
                                (PlutoGridSelectingMode item) {
                          final color = gridSelectingMode == item ? Colors.blue : null;

                          return DropdownMenuItem<PlutoGridSelectingMode>(
                            value: item,
                            child: Text(
                              item.toShortString(),
                              style: TextStyle(color: color),
                            ),
                          );
                        }).toList(),
                        onChanged: (PlutoGridSelectingMode? mode) {
                          setGridSelectingMode(mode);
                        },
                      ),
                    ),
                    ElevatedButton(
                      child: const Text('Toggle filter'),
                      onPressed: handleToggleColumnFilter,
                    ),
                  ],
                ),
              ),
            );
          },
          createFooter: (stateManager) => PlutoPagination(stateManager),
          configuration: PlutoGridConfiguration(
            // rowHeight: 30.0,
            
            scrollbarConfig: const PlutoGridScrollbarConfig(
              isAlwaysShown: false,
              scrollbarThickness: 8,
              scrollbarThicknessWhileDragging: 10,
            ),
            
            // localeText: const PlutoGridLocaleText.korean(),
            // columnFilterConfig: PlutoGridColumnFilterConfig(
            //   filters: const [
            //     ...FilterHelper.defaultFilters,
            //     ClassYouImplemented(),
            //   ],
            //   resolveDefaultColumnFilter: (column, resolver) {
            //     if (column.field == 'column3') {
            //       return resolver<PlutoFilterTypeGreaterThan>()
            //           as PlutoFilterType;
            //     }
            //
            //     return resolver<PlutoFilterTypeContains>() as PlutoFilterType;
            //   },
            // ),
          ),
        ),
      ),
    );
  }
}

class ClassYouImplemented implements PlutoFilterType {
  String get title => 'Custom contains';

  get compare => ({
        required String? base,
        required String? search,
        required PlutoColumn? column,
      }) {
        var keys = search!.split(',');

        return keys.contains(base);
      };

  const ClassYouImplemented();
}
