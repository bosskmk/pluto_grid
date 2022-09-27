import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_menu_bar/pluto_menu_bar.dart';

import '../dummy_data/development.dart';
import 'home_screen.dart';

class DevelopmentScreen extends StatefulWidget {
  static const routeName = 'development';

  const DevelopmentScreen({Key? key}) : super(key: key);

  @override
  _DevelopmentScreenState createState() => _DevelopmentScreenState();
}

class _DevelopmentScreenState extends State<DevelopmentScreen> {
  final List<PlutoColumn> columns = [];

  final List<PlutoRow> rows = [];

  final List<PlutoColumnGroup> columnGroups = [];

  late PlutoGridStateManager stateManager;

  Color Function(PlutoRowColorContext)? rowColorCallback;

  TextDirection textDirection = TextDirection.ltr;

  @override
  void initState() {
    super.initState();

    /// Test A
    // columns.addAll(testColumnsA);
    // columnGroups.addAll(testColumnGroupsA);
    // rows.addAll(DummyData.rowsByColumns(length: 10000, columns: columns));
    // rowColorCallback = (PlutoRowColorContext rowColorContext) {
    //   return rowColorContext.row.cells['column2']?.value == 'green'
    //       ? const Color(0xFFE2F6DF)
    //       : Colors.white;
    // };

    /// Test B
    columns.addAll(DummyData(10, 0).columns);
    columnGroups.addAll(testColumnGroupsB);
    DummyData.fetchRows(
      columns,
      chunkSize: 100,
      chunkCount: 10,
    ).then((fetchedRows) {
      PlutoGridStateManager.initializeRowsAsync(columns, fetchedRows)
          .then((initializedRows) {
        stateManager.refRows.addAll(FilteredList(initialList: initializedRows));
        stateManager.notifyListeners();
      });
    });
    columns[0].enableRowDrag = true;
    columns[0].enableRowChecked = true;
    columns[0].footerRenderer = (c) {
      return PlutoAggregateColumnFooter(
        rendererContext: c,
        type: PlutoAggregateColumnType.count,
        format: 'CheckedCount : #,###',
        alignment: Alignment.center,
        filter: (cell) => cell.row.checked == true,
      );
    };
    columns[1].footerRenderer = (c) {
      return PlutoAggregateColumnFooter(
        rendererContext: c,
        type: PlutoAggregateColumnType.sum,
        format: '#,###',
        alignment: Alignment.center,
        formatAsCurrency: true,
        filter: (cell) => cell.row.checked == true,
        titleSpanBuilder: (text) {
          return [
            const TextSpan(text: 'CheckedSum : '),
            TextSpan(text: text),
          ];
        },
      );
    };
  }

  void handleOnRowChecked(PlutoGridOnRowCheckedEvent event) {
    if (event.isRow) {
      print('Toggled A Row.');
      print(event.row?.cells['column1']?.value);
    } else {
      print('Toggled All Rows.');
      print(stateManager.checkedRows.length);
    }
  }

  void setTextDirection(TextDirection direction) {
    setState(() {
      textDirection = direction;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Directionality(
          textDirection: textDirection,
          child: PlutoGrid(
            columns: columns,
            rows: rows,
            columnGroups: columnGroups,
            // mode: PlutoGridMode.selectWithOneTap,
            onChanged: (PlutoGridOnChangedEvent event) {
              print(event);
            },
            onLoaded: (PlutoGridOnLoadedEvent event) {
              stateManager = event.stateManager;
            },
            onSorted: (PlutoGridOnSortedEvent event) {
              print(event);
            },
            // onSelected: (event) {
            //   print(event.cell!.value);
            // },
            // onRowChecked: handleOnRowChecked,
            // onRowsMoved: (event) {
            //   print(event.idx);
            //   print(event.rows);
            // },
            // onRowDoubleTap: (e) {
            //   print('Double click A Row.');
            //   print(e.row?.cells['column1']?.value);
            // },
            // onRowSecondaryTap: (e) {
            //   print('Secondary click A Row.(${e.offset})');
            //   print(e.row?.cells['column1']?.value);
            // },
            createHeader: (PlutoGridStateManager stateManager) {
              // stateManager.headerHeight = 200;
              return _Header(
                stateManager: stateManager,
                columns: columns,
                textDirection: textDirection,
                setTextDirection: setTextDirection,
              );
            },
            // createFooter: (stateManager) {
            //   stateManager.setPageSize(30, notify: false);
            //   return PlutoPagination(stateManager);
            // },
            rowColorCallback: rowColorCallback,
            configuration: PlutoGridConfiguration(
              // columnHeight: 30.0,
              // columnFilterHeight: 30.0,
              // rowHeight: 30.0,
              // defaultCellPadding: 15,
              // defaultColumnTitlePadding: 15,
              // iconSize: 15,
              style: PlutoGridStyleConfig(
                enableColumnBorderVertical: true,
                enableColumnBorderHorizontal: true,
                enableCellBorderVertical: true,
                enableCellBorderHorizontal: true,
                // oddRowColor: Colors.amber,
                evenRowColor: const Color(0xFFF6F6F6),
                gridBorderRadius: BorderRadius.circular(10),
                gridPopupBorderRadius: BorderRadius.circular(7),
                // columnAscendingIcon: const Icon(
                //   Icons.arrow_upward,
                //   color: Colors.cyan,
                // ),
                // columnDescendingIcon: const Icon(
                //   Icons.arrow_downward,
                //   color: Colors.pink,
                // ),
              ),
              // enableGridBorderShadow: true,
              enableMoveHorizontalInEditing: true,
              // enableRowColorAnimation: false,
              // columnSizeConfig: const PlutoGridColumnSizeConfig(
              // autoSizeMode: PlutoAutoSizeMode.equal,
              // resizeMode: PlutoResizeMode.pushAndPull,
              // restoreAutoSizeAfterHideColumn: true,
              // restoreAutoSizeAfterFrozenColumn: false,
              // restoreAutoSizeAfterMoveColumn: false,
              // restoreAutoSizeAfterInsertColumn: false,
              // restoreAutoSizeAfterRemoveColumn: false,
              // ),
              // checkedColor: const Color(0x876FB0FF),
              enterKeyAction: PlutoGridEnterKeyAction.toggleEditing,
              enableMoveDownAfterSelecting: false,
              scrollbar: const PlutoGridScrollbarConfig(
                isAlwaysShown: false,
                scrollbarThickness: 8,
                scrollbarThicknessWhileDragging: 10,
              ),
              // localeText: const PlutoGridLocaleText.korean(),
              columnFilter: PlutoGridColumnFilterConfig(
                filters: const [
                  ...FilterHelper.defaultFilters,
                  ClassYouImplemented(),
                ],
                resolveDefaultColumnFilter: (column, resolver) {
                  if (column.field == 'column3') {
                    return resolver<PlutoFilterTypeGreaterThan>()
                        as PlutoFilterType;
                  }

                  return resolver<PlutoFilterTypeContains>() as PlutoFilterType;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClassYouImplemented implements PlutoFilterType {
  @override
  String get title => 'Custom contains';

  @override
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

class _Header extends StatefulWidget {
  final PlutoGridStateManager stateManager;

  final List<PlutoColumn> columns;

  final TextDirection textDirection;

  final void Function(TextDirection) setTextDirection;

  const _Header({
    required this.stateManager,
    required this.columns,
    required this.textDirection,
    required this.setTextDirection,
    Key? key,
  }) : super(key: key);

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  @override
  void initState() {
    super.initState();

    widget.stateManager.setSelectingMode(gridSelectingMode, notify: false);

    textDirection = widget.textDirection;
  }

  PlutoGridSelectingMode gridSelectingMode = PlutoGridSelectingMode.row;

  late TextDirection textDirection;

  _Locale currentLocale = _Locale.english;

  void handleAddColumnButton(PlutoColumnFrozen frozen) {
    widget.stateManager.insertColumns(
      0,
      [
        PlutoColumn(
          title: faker.food.cuisine(),
          field: 'new_${DateTime.now()}',
          type: PlutoColumnType.text(),
          frozen: frozen,
        ),
      ],
    );
  }

  void handleAddRowButton({int? count}) {
    final List<PlutoRow> rows = count == null
        ? [DummyData.rowByColumns(widget.columns)]
        : DummyData.rowsByColumns(length: count, columns: widget.columns);

    widget.stateManager.prependRows(rows);
  }

  void handleRemoveCurrentColumnButton() {
    if (widget.stateManager.currentColumn != null) {
      widget.stateManager.removeColumns([widget.stateManager.currentColumn!]);
    }
  }

  void handleRemoveAllColumnsButton() {
    widget.stateManager.removeColumns(
      widget.stateManager.refColumns.originalList,
    );
  }

  void handleRemoveCurrentRowButton() {
    widget.stateManager.removeCurrentRow();
  }

  void handleRemoveSelectedRowsButton() {
    widget.stateManager.removeRows(widget.stateManager.currentSelectingRows);
  }

  void handleRemoveAllRowsButton() {
    widget.stateManager.removeRows(widget.stateManager.refRows.originalList);
  }

  void handleToggleColumnGroup() {
    widget.stateManager.setShowColumnGroups(
      !widget.stateManager.showColumnGroups,
    );
  }

  void handleToggleColumnTitle() {
    widget.stateManager
        .setShowColumnTitle(!widget.stateManager.showColumnTitle);
  }

  void handleToggleColumnFilter() {
    widget.stateManager
        .setShowColumnFilter(!widget.stateManager.showColumnFilter);
  }

  void handleToggleColumnFooter() {
    widget.stateManager
        .setShowColumnFooter(!widget.stateManager.showColumnFooter);
  }

  void handleSelectingMode(Object? mode) {
    setState(() {
      gridSelectingMode = mode as PlutoGridSelectingMode;
      widget.stateManager.setSelectingMode(mode);
    });
  }

  void handleSelectAll() {
    widget.stateManager.setAllCurrentSelecting();
  }

  void handleUnselect() {
    widget.stateManager.clearCurrentSelecting();
  }

  void handleAutoSize(Object? mode) {
    setState(() {
      widget.stateManager.setColumnSizeConfig(
        widget.stateManager.columnSizeConfig.copyWith(
          autoSizeMode: mode as PlutoAutoSizeMode,
        ),
      );
    });
  }

  void handleRestoreAutoSize(_RestoreAutoSizeOptions option, bool? flag) {
    setState(() {
      PlutoGridColumnSizeConfig config;
      switch (option) {
        case _RestoreAutoSizeOptions.restoreAutoSizeAfterHideColumn:
          config = widget.stateManager.columnSizeConfig.copyWith(
            restoreAutoSizeAfterHideColumn: flag,
          );
          break;
        case _RestoreAutoSizeOptions.restoreAutoSizeAfterFrozenColumn:
          config = widget.stateManager.columnSizeConfig.copyWith(
            restoreAutoSizeAfterFrozenColumn: flag,
          );
          break;
        case _RestoreAutoSizeOptions.restoreAutoSizeAfterMoveColumn:
          config = widget.stateManager.columnSizeConfig.copyWith(
            restoreAutoSizeAfterMoveColumn: flag,
          );
          break;
        case _RestoreAutoSizeOptions.restoreAutoSizeAfterInsertColumn:
          config = widget.stateManager.columnSizeConfig.copyWith(
            restoreAutoSizeAfterInsertColumn: flag,
          );
          break;
        case _RestoreAutoSizeOptions.restoreAutoSizeAfterRemoveColumn:
          config = widget.stateManager.columnSizeConfig.copyWith(
            restoreAutoSizeAfterRemoveColumn: flag,
          );
          break;
      }
      widget.stateManager.setColumnSizeConfig(config);
    });
  }

  void handleResize(Object? mode) {
    setState(() {
      widget.stateManager.setColumnSizeConfig(
        widget.stateManager.columnSizeConfig.copyWith(
          resizeMode: mode as PlutoResizeMode,
        ),
      );
    });
  }

  void handleLocale(Object? locale) {
    setState(() {
      currentLocale = locale as _Locale;

      PlutoGridLocaleText localeText;

      switch (currentLocale) {
        case _Locale.english:
          localeText = const PlutoGridLocaleText();
          break;
        case _Locale.korean:
          localeText = const PlutoGridLocaleText.korean();
          break;
        case _Locale.china:
          localeText = const PlutoGridLocaleText.china();
          break;
        case _Locale.russian:
          localeText = const PlutoGridLocaleText.russian();
          break;
        case _Locale.czech:
          localeText = const PlutoGridLocaleText.czech();
          break;
        case _Locale.brazilianPortuguese:
          localeText = const PlutoGridLocaleText.brazilianPortuguese();
          break;
        case _Locale.spanish:
          localeText = const PlutoGridLocaleText.spanish();
          break;
        case _Locale.persian:
          localeText = const PlutoGridLocaleText.persian();
          break;
        case _Locale.arabic:
          localeText = const PlutoGridLocaleText.arabic();
          break;
      }

      widget.stateManager.setConfiguration(
        widget.stateManager.configuration.copyWith(
          localeText: localeText,
        ),
      );

      widget.stateManager.forceUpdate();
    });
  }

  void handleTextDirection(Object? direction) {
    setState(() {
      textDirection = direction as TextDirection;
      widget.setTextDirection(direction);
    });
  }

  void setGridSelectingMode(PlutoGridSelectingMode? mode) {
    if (gridSelectingMode == mode || mode == null) {
      return;
    }

    setState(() {
      gridSelectingMode = mode;
      widget.stateManager.setSelectingMode(mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlutoMenuBar(
      borderColor: Colors.transparent,
      textStyle: const TextStyle(
        color: Colors.black,
        fontSize: 14,
      ),
      menus: [
        PlutoMenuItem(
          title: 'Home',
          onTap: () {
            Navigator.pushNamed(context, HomeScreen.routeName);
          },
        ),
        PlutoMenuItem(
          title: 'Add & Remove',
          children: [
            PlutoMenuItem(
              title: 'Column',
              children: [
                PlutoMenuItem(
                  title: 'Add to start',
                  onTap: () {
                    handleAddColumnButton(PlutoColumnFrozen.start);
                  },
                ),
                PlutoMenuItem(
                  title: 'Add to body',
                  onTap: () {
                    handleAddColumnButton(PlutoColumnFrozen.none);
                  },
                ),
                PlutoMenuItem(
                  title: 'Add to end',
                  onTap: () {
                    handleAddColumnButton(PlutoColumnFrozen.end);
                  },
                ),
                PlutoMenuItem(
                  title: 'Remove current column',
                  onTap: handleRemoveCurrentColumnButton,
                ),
                PlutoMenuItem(
                  title: 'Remove all columns',
                  onTap: handleRemoveAllColumnsButton,
                ),
              ],
            ),
            PlutoMenuItem(
              title: 'Row',
              children: [
                PlutoMenuItem(
                  title: 'Add 1 row',
                  onTap: () {
                    handleAddRowButton(count: 1);
                  },
                ),
                PlutoMenuItem(
                  title: 'Add 10 rows',
                  onTap: () {
                    handleAddRowButton(count: 10);
                  },
                ),
                PlutoMenuItem(
                  title: 'Add 100 rows',
                  onTap: () {
                    handleAddRowButton(count: 100);
                  },
                ),
                PlutoMenuItem(
                  title: 'Remove current row',
                  onTap: handleRemoveCurrentRowButton,
                ),
                PlutoMenuItem(
                  title: 'Remove selected rows',
                  onTap: handleRemoveSelectedRowsButton,
                ),
                PlutoMenuItem(
                  title: 'Remove all rows',
                  onTap: handleRemoveAllRowsButton,
                ),
              ],
            ),
          ],
        ),
        PlutoMenuItem(
          title: 'Show',
          children: [
            PlutoMenuItem(
              title: 'Toggle column group',
              onTap: handleToggleColumnGroup,
            ),
            PlutoMenuItem(
              title: 'Toggle column title',
              onTap: handleToggleColumnTitle,
            ),
            PlutoMenuItem(
              title: 'Toggle column filter',
              onTap: handleToggleColumnFilter,
            ),
            PlutoMenuItem(
              title: 'Toggle column footer',
              onTap: handleToggleColumnFooter,
            ),
          ],
        ),
        PlutoMenuItem(
          title: 'Select',
          children: [
            PlutoMenuItem(title: 'Select all', onTap: handleSelectAll),
            PlutoMenuItem(title: 'Unselect all', onTap: handleUnselect),
            PlutoMenuItem(title: 'Select mode', enable: false),
            PlutoMenuItem.radio(
              title: 'Mode',
              initialRadioValue: gridSelectingMode,
              radioItems: PlutoGridSelectingMode.values,
              getTitle: (option) => (option as PlutoGridSelectingMode).name,
              onChanged: handleSelectingMode,
            ),
          ],
        ),
        PlutoMenuItem(
          title: 'Size',
          children: [
            PlutoMenuItem(
              title: 'AutoSizeMode',
              enable: false,
            ),
            PlutoMenuItem.radio(
              title: 'AutoSize',
              initialRadioValue:
                  widget.stateManager.columnSizeConfig.autoSizeMode,
              radioItems: PlutoAutoSizeMode.values,
              onChanged: handleAutoSize,
              getTitle: (option) => (option as PlutoAutoSizeMode).name,
            ),
            PlutoMenuItem(
              title: 'AutoSize options',
              children: [
                PlutoMenuItem.checkbox(
                  title: 'Restore after hide column',
                  initialCheckValue: widget.stateManager.columnSizeConfig
                      .restoreAutoSizeAfterHideColumn,
                  onChanged: (flag) => handleRestoreAutoSize(
                    _RestoreAutoSizeOptions.restoreAutoSizeAfterHideColumn,
                    flag,
                  ),
                ),
                PlutoMenuItem.checkbox(
                  title: 'Restore after frozen column',
                  initialCheckValue: widget.stateManager.columnSizeConfig
                      .restoreAutoSizeAfterFrozenColumn,
                  onChanged: (flag) => handleRestoreAutoSize(
                    _RestoreAutoSizeOptions.restoreAutoSizeAfterFrozenColumn,
                    flag,
                  ),
                ),
                PlutoMenuItem.checkbox(
                  title: 'Restore after move column',
                  initialCheckValue: widget.stateManager.columnSizeConfig
                      .restoreAutoSizeAfterMoveColumn,
                  onChanged: (flag) => handleRestoreAutoSize(
                    _RestoreAutoSizeOptions.restoreAutoSizeAfterMoveColumn,
                    flag,
                  ),
                ),
                PlutoMenuItem.checkbox(
                  title: 'Restore after insert column',
                  initialCheckValue: widget.stateManager.columnSizeConfig
                      .restoreAutoSizeAfterInsertColumn,
                  onChanged: (flag) => handleRestoreAutoSize(
                    _RestoreAutoSizeOptions.restoreAutoSizeAfterInsertColumn,
                    flag,
                  ),
                ),
                PlutoMenuItem.checkbox(
                  title: 'Restore after remove column',
                  initialCheckValue: widget.stateManager.columnSizeConfig
                      .restoreAutoSizeAfterRemoveColumn,
                  onChanged: (flag) => handleRestoreAutoSize(
                    _RestoreAutoSizeOptions.restoreAutoSizeAfterRemoveColumn,
                    flag,
                  ),
                ),
              ],
            ),
            PlutoMenuItem(
              title: 'ReSizeMode',
              enable: false,
            ),
            PlutoMenuItem.radio(
              title: 'Resize',
              initialRadioValue:
                  widget.stateManager.columnSizeConfig.resizeMode,
              radioItems: PlutoResizeMode.values,
              onChanged: handleResize,
              getTitle: (option) => (option as PlutoResizeMode).name,
            ),
          ],
        ),
        PlutoMenuItem(
          title: 'Internationalization',
          children: [
            PlutoMenuItem(
              title: 'Language',
              children: [
                PlutoMenuItem.radio(
                  title: 'Locale',
                  initialRadioValue: currentLocale,
                  radioItems: _Locale.values,
                  onChanged: handleLocale,
                  getTitle: (option) => (option as _Locale).name,
                ),
              ],
            ),
            PlutoMenuItem(
              title: 'TextDirection',
              children: [
                PlutoMenuItem.radio(
                  title: 'TextDirection',
                  initialRadioValue: textDirection,
                  radioItems: TextDirection.values,
                  onChanged: handleTextDirection,
                  getTitle: (option) =>
                      (option as TextDirection).name.toUpperCase(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

final testColumnsA = [
  PlutoColumn(
    title: 'column1',
    field: 'column1',
    type: PlutoColumnType.text(),
    enableRowDrag: true,
    enableRowChecked: true,
    enableContextMenu: false,
    enableDropToResize: true,
    enableAutoEditing: true,
    titleTextAlign: PlutoColumnTextAlign.right,
    titleSpan: const TextSpan(
      children: [
        WidgetSpan(
          child: Text(
            '* ',
            style: TextStyle(color: Colors.red),
          ),
          alignment: PlaceholderAlignment.bottom,
        ),
        TextSpan(text: 'column1'),
      ],
    ),
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
              rendererContext.stateManager.insertRows(
                rendererContext.rowIdx,
                rendererContext.stateManager.getNewRows(count: 1),
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
              rendererContext.stateManager.removeRows([rendererContext.row]);
            },
            iconSize: 18,
            color: Colors.red,
            padding: const EdgeInsets.all(0),
          ),
          Expanded(
            child: Text(
              '${rendererContext.row.sortIdx.toString()}(${rendererContext.row.cells[rendererContext.column.field]!.value.toString()})',
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
    textAlign: PlutoColumnTextAlign.right,
    titleTextAlign: PlutoColumnTextAlign.right,
    frozen: PlutoColumnFrozen.end,
    type: PlutoColumnType.select(
      <String>['red', 'blue', 'green'],
      enableColumnFilter: true,
    ),
    renderer: (rendererContext) {
      Color textColor = Colors.black;

      if (rendererContext.cell.value == 'red') {
        textColor = Colors.red;
      } else if (rendererContext.cell.value == 'blue') {
        textColor = Colors.blue;
      } else if (rendererContext.cell.value == 'green') {
        textColor = Colors.green;
      }

      return Text(
        rendererContext.cell.value.toString(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        textAlign: rendererContext.column.textAlign.value,
      );
    },
  ),
  PlutoColumn(
    title: 'column3',
    field: 'column3',
    textAlign: PlutoColumnTextAlign.left,
    titleTextAlign: PlutoColumnTextAlign.center,
    enableAutoEditing: true,
    type: PlutoColumnType.date(
        // headerFormat: 'yyyy 년 MM 월',
        // startDate: DateTime(2022, 01, 09),
        // endDate: DateTime(2022, 08, 10),
        ),
  ),
  PlutoColumn(
    title: 'column4',
    field: 'column4',
    textAlign: PlutoColumnTextAlign.center,
    titleTextAlign: PlutoColumnTextAlign.right,
    type: PlutoColumnType.time(),
  ),
  PlutoColumn(
    title: 'column5',
    field: 'column5',
    textAlign: PlutoColumnTextAlign.center,
    titleTextAlign: PlutoColumnTextAlign.left,
    type: PlutoColumnType.number(
      negative: true,
      format: '#,###.###',
      allowFirstDot: true,
    ),
  ),
  PlutoColumn(
    title: 'column6',
    field: 'column6',
    type: PlutoColumnType.text(),
    enableFilterMenuItem: false,
    enableEditingMode: false,
    renderer: (rendererContext) {
      return Image.asset(
        'assets/images/cat.jpg',
        fit: BoxFit.fitWidth,
      );
    },
  ),
  PlutoColumn(
    title: 'column7',
    field: 'column7',
    type: PlutoColumnType.number(),
    enableFilterMenuItem: false,
    enableEditingMode: false,
    // NEW Custom cellPadding
    cellPadding: EdgeInsets.zero,
    width: 80,
    renderer: (rendererContext) {
      return Container(
        color:
            rendererContext.cell.value % 2 == 0 ? Colors.yellow : Colors.teal,
      );
    },
  ),
];

final testColumnGroupsA = [
  PlutoColumnGroup(
    title: 'Expanded Column Group',
    fields: ['column1'],
    expandedColumn: true,
  ),
  PlutoColumnGroup(
    title: 'Group A',
    children: [
      PlutoColumnGroup(title: 'SubA', fields: ['column2']),
      PlutoColumnGroup(
        title: 'SubB',
        fields: ['column3'],
        expandedColumn: true,
      ),
    ],
  ),
  PlutoColumnGroup(
    title: 'Group B',
    fields: ['column4', 'column5', 'column6'],
  ),
  PlutoColumnGroup(
    title: 'Group C',
    fields: ['column7'],
  ),
];

final testColumnGroupsB = [
  PlutoColumnGroup(
    title: 'Expanded Column Group',
    fields: ['0'],
    expandedColumn: true,
  ),
  PlutoColumnGroup(
    title: 'Group A',
    children: [
      PlutoColumnGroup(title: 'SubA', fields: ['1']),
      PlutoColumnGroup(
        title: 'SubB',
        fields: ['2'],
        expandedColumn: true,
      ),
    ],
  ),
  PlutoColumnGroup(
    title: 'Group B',
    fields: ['3', '4', '5'],
  ),
  PlutoColumnGroup(
    title: 'Group C',
    fields: ['6'],
  ),
];

enum _RestoreAutoSizeOptions {
  restoreAutoSizeAfterHideColumn,
  restoreAutoSizeAfterFrozenColumn,
  restoreAutoSizeAfterMoveColumn,
  restoreAutoSizeAfterInsertColumn,
  restoreAutoSizeAfterRemoveColumn,
}

enum _Locale {
  english,
  korean,
  china,
  russian,
  czech,
  brazilianPortuguese,
  spanish,
  persian,
  arabic,
}
