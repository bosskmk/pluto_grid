import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/src/lac/excel_filters.dart';

import '../../pluto_grid.dart';

class EnterIntent extends Intent {}

class EscapeIntent extends Intent {}

enum FilterType {
  contains,
  greater,
  lesser,
  before,
  after,
}

// ignore: must_be_immutable
class ExcelMenu extends StatefulWidget {
  BuildContext? context;
  PlutoGridStateManager? stateManager;
  PlutoColumn? column;

  ExcelMenu({required this.context, this.stateManager, required this.column});

  @override
  _ExcelMenuState createState() => _ExcelMenuState();
}

class _ExcelMenuState extends State<ExcelMenu> {
  List<String> filterItems = [];
  List<int> filterIndex = [];
  late ExcelFilters excelFilters = ExcelFilters(stateManager: widget.stateManager!);

  late List<PlutoRow?> rows = widget.stateManager!.refRows!.originalList;

  TextEditingController containsController = TextEditingController();
  TextEditingController greaterController = TextEditingController();
  TextEditingController lesserController = TextEditingController();

  TextEditingController afterMinController = TextEditingController();
  TextEditingController afterHourController = TextEditingController();
  TextEditingController afterDayController = TextEditingController();

  TextEditingController beforeMinController = TextEditingController();
  TextEditingController beforeHourController = TextEditingController();
  TextEditingController beforeDayController = TextEditingController();

  FocusNode mainFocusNode = FocusNode();

  // Map<String, dynamic> filterData = <String, dynamic> {'Text': {'Contains': 'Baik'}};

  late String currentColumn = widget.column!.field;

  late Map<String, TextEditingController> controllerMap = {
    'Contains': containsController,
    'Greater': greaterController,
    'Lesser': lesserController,
    'BeforeMin': beforeMinController,
    'BeforeHour': beforeHourController,
    'BeforeDay': beforeDayController,
    'AfterMin': afterMinController,
    'AfterHour': afterHourController,
    'AfterDay': afterDayController,
  };

  late Map<String, Map<String, String>> filterData = widget.stateManager!.filtersNew;

  Map<String, bool> checked = {};
  List<String> checkedList = [];

  // List<String> indexCheckedList = [];
  late PlutoColumnType? columnType = widget.column!.type;
  var filter = '';
  int fullCount = 0;

  int isAfter = 0;

  /// Filter using the text input
  List<String> filterRows({bool reset = true}) {
    print('Filter Rows');

    if (reset) {
      resetFilter();
    }

    print('Filter Existing Stuff');
    // Apply other saved filters
    filterData.forEach((column, filterMap) {
      print('Column: $column');
      // Use the text field to filter the current column
      if (column != currentColumn) {
        int beforeUnix = 0;
        int afterUnix = 0;

        filterMap.forEach((key, value) {
          print('Key: $key');
          print('Value: $value');

          if (key == 'Contains') {
            filterIndex = excelFilters.containsFilter(filterValue: value, filterIndex: filterIndex, column: column);
          } else if (key == 'Greater') {
            filterIndex = excelFilters.numberFilter(filterValue: value, filterIndex: filterIndex, isGreater: true, column: column);
          } else if (key == 'Lesser') {
            filterIndex = excelFilters.numberFilter(filterValue: value, filterIndex: filterIndex, isGreater: false, column: column);
          } else if (key == 'BeforeMin') {
            beforeUnix += (double.parse(value) * 60 * 1000).toInt();
          } else if (key == 'BeforeHour') {
            beforeUnix += (double.parse(value) * 60 * 60 * 1000).toInt();
          } else if (key == 'BeforeDay') {
            beforeUnix += (double.parse(value) * 24 * 60 * 60 * 1000).toInt();
          } else if (key == 'AfterMin') {
            afterUnix += (double.parse(value) * 60 * 1000).toInt();
          } else if (key == 'AfterHour') {
            afterUnix += (double.parse(value) * 60 * 60 * 1000).toInt();
          } else if (key == 'AfterDay') {
            afterUnix += (double.parse(value) * 24 * 60 * 60 * 1000).toInt();
          }
        });

        if (beforeUnix != 0) {
          filterIndex = excelFilters.dateFilter(filterValue: beforeUnix + DateTime.now().millisecondsSinceEpoch, filterIndex: filterIndex, isBefore: true, column: column);
        }

        if (afterUnix != 0) {
          filterIndex = excelFilters.dateFilter(filterValue: afterUnix + DateTime.now().millisecondsSinceEpoch, filterIndex: filterIndex, isBefore: false, column: column);
        }
      }
    });

    // Filter using text fields

    if (containsController.value.text.isNotEmpty) {
      // filterIndex = containsFilter(filterValue: containsController.value.text, filterIndex: filterIndex);
      filterIndex = excelFilters.containsFilter(filterValue: containsController.value.text, filterIndex: filterIndex, column: currentColumn);
    }

    if (columnType.isDate) {
      if (getUnix(isBefore: false) != 0) {
        filterIndex = excelFilters.dateFilter(filterValue: getUnix(isBefore: false), filterIndex: filterIndex, isBefore: false, column: currentColumn);
      }

      if (getUnix(isBefore: true) != 0) {
        filterIndex = excelFilters.dateFilter(filterValue: getUnix(isBefore: true), filterIndex: filterIndex, isBefore: true, column: currentColumn);
      }

    }

    if (columnType.isNumber) {
      if (greaterController.value.text.isNotEmpty) {
        filterIndex = excelFilters.numberFilter(filterValue: greaterController.value.text, filterIndex: filterIndex, isGreater: true, column: currentColumn);
      }

      if (lesserController.value.text.isNotEmpty) {
        filterIndex = excelFilters.numberFilter(filterValue: lesserController.value.text, filterIndex: filterIndex, isGreater: false, column: currentColumn);
      }
    }

    filterIndex = filterIndex.toSet().toList();
    filterIndex.sort((a, b) => a.compareTo(b));

    if (filterItems.length == 1) {
      filterItems = [];
      checkedList = [];
    }

    filterItems = [];
    filterIndex.forEach((index) {
      filterItems.add(rows[index]!.cells[currentColumn]!.value.toString());
    });

    filterItems = filterItems.toSet().toList();
    filterItems.sort((a, b) => a.compareTo(b));
    fullCount = filterItems.length;

    print(filterIndex);

    return filterItems;
  }

  // List<int> dateFilter({required int filterValue, required List<int> filterIndex, required bool isBefore, String? column}) {
  //   column ??= currentColumn;
  //
  //   filterIndex.removeWhere((index) {
  //     String element = rows[index]!.cells[column]!.value.toString();
  //     if (element == 'Select All') {
  //       return false;
  //     }
  //
  //     bool isRemove = true;
  //
  //     if (isBefore) {
  //       isRemove = DateTime.parse(element).millisecondsSinceEpoch > filterValue;
  //     } else {
  //       isRemove = DateTime.parse(element).millisecondsSinceEpoch < filterValue;
  //     }
  //
  //     if (isRemove) {
  //       checkedList.remove(element);
  //       return true;
  //     } else {
  //       if (!checkedList.contains(element)) {
  //         checkedList.add(element);
  //       }
  //       return false;
  //     }
  //   });
  //
  //   return filterIndex;
  // }
  //
  // List<int> numberFilter({required String filterValue, required List<int> filterIndex, required bool isGreater, String? column}) {
  //   column ??= currentColumn;
  //
  //   double number = double.parse(filterValue);
  //   filterIndex.removeWhere((index) {
  //     String element = rows[index]!.cells[column]!.value.toString();
  //
  //     if (element == 'Select All') {
  //       return false;
  //     }
  //
  //     bool isRemove = true;
  //
  //     if (isGreater) {
  //       isRemove = double.parse(element) < number;
  //     } else {
  //       isRemove = double.parse(element) > number;
  //     }
  //
  //     if (isRemove) {
  //       checkedList.remove(element);
  //       return true;
  //     } else {
  //       if (!checkedList.contains(element)) {
  //         checkedList.add(element);
  //       }
  //       return false;
  //     }
  //   });
  //   return filterIndex;
  // }
  //
  // List<int> containsFilter({required String filterValue, required List<int> filterIndex, String? column}) {
  //   column ??= currentColumn;
  //
  //   print("Contains Filter");
  //   print(filterValue);
  //   print(column);
  //
  //   filterIndex.removeWhere((index) {
  //     String element = rows[index]!.cells[column]!.value.toString();
  //
  //     if (element == 'Select All') {
  //       return false;
  //     }
  //     if (!element.toLowerCase().contains(filterValue.toLowerCase())) {
  //       checkedList.remove(element);
  //       return true;
  //     } else {
  //       if (!checkedList.contains(element)) {
  //         checkedList.add(element);
  //       }
  //       return false;
  //     }
  //   });
  //   return filterIndex;
  // }


  int getUnix({bool isBefore = false}) {
    int dayUnix = 0;
    int hourUnix = 0;
    int minuteUnix = 0;

    String dayString = isBefore ? beforeDayController.value.text : afterDayController.value.text;
    String hourString = isBefore ? beforeHourController.value.text : afterHourController.value.text;
    String minuteString = isBefore ? beforeMinController.value.text : afterMinController.value.text;

    if (double.tryParse(dayString) != null) {
      dayUnix = (double.parse(dayString) * 24 * 60 * 60 * 1000).toInt();
    }

    if (double.tryParse(hourString) != null) {
      hourUnix = (double.parse(hourString) * 60 * 60 * 1000).toInt();
    }

    if (double.tryParse(minuteString) != null) {
      minuteUnix = (double.parse(minuteString) * 60 * 1000).toInt();
    }

    int delta = dayUnix + hourUnix + minuteUnix;

    if (delta == 0) {
      return 0;
    }

    int unix = DateTime.now().millisecondsSinceEpoch + delta;
    return unix;
  }

  void resetFilter({bool initial = false}) {
    print('Reset Filter');

    filterItems = [];

    // Populate with the original/full list
    rows.forEach((row) {
      filterItems.add(row!.cells[widget.column!.field]!.value.toString());
      filterIndex.add(row.sortIdx as int);
    });

    filterItems = filterItems.toSet().toList();
    filterItems.sort((a, b) => a.compareTo(b));
    fullCount = filterItems.length;

    // If initial then use visible rows to set checked items
    if (initial) {
      print(widget.column!.type.toString());

      // Use visible rows to set if checked
      widget.stateManager!.rows.forEach((row) {
        checkedList.add(row!.cells[currentColumn]!.value.toString());
      });
      checkedList = checkedList.toSet().toList();

      // Apply all filters
      filterData.forEach((column, value) {});

      // Apply past filters
      if (filterData.containsKey(currentColumn)) {
        Map<String, String>? filters = filterData[currentColumn];

        // Add data to inputs
        filters!.forEach((key, value) {
          controllerMap[key]!.text = value;
        });

        // Filter the rows, to apply other rows or previous filtering
        // This is loosing the un-checked items
      }
      filterRows(reset: false);
    } else {
      // if not initial then check all items
      checkedList = [];
      checkedList.addAll(filterItems);
    }

    // Add select all to top
    if (!filterItems.contains('Select All')) {
      filterItems.insert(0, 'Select All');
    }

    if (!checkedList.contains('Select All') && checkedList.isNotEmpty) {
      checkedList.add('Select All');
    }
  }

  bool? getShowAllChecked() {

    print("Checked");
    print(checkedList.length);
    print("Available");
    print(filterItems.length);

    if (checkedList.length == filterItems.length) {
      // All Selected
      return true;
    } else if (checkedList.isEmpty || checkedList.length == 1) {
      // Non Selected
      return false;
    } else {
      // Some Selected
      return null;
    }
  }


  Map<String, Map<String, String>> saveFilter() {
    // Update only this column

    Map<String, String> saved = {};
    controllerMap.forEach((key, controller) {
      if (controller.value.text.isNotEmpty) {
        saved[key] = controller.value.text;
      }
    });

    if(saved.isNotEmpty) {
      filterData[currentColumn] = saved;
    }else{
      filterData.remove(currentColumn);
    }

    return filterData;
  }

  void saveAndClose() {

    Map<String, Map<String, String>> newData = saveFilter();
    widget.stateManager!.setFiltersNewColumns(newData.keys.toList());
    print("Filter Columns");
    print(widget.stateManager!.filtersNewColumns);
    // widget.stateManager!.resetCurrentState(notify: true);
    widget.stateManager!.resizeColumn(widget.stateManager!.columns[0].key, 0.00001);

    widget.stateManager!.setFilter((element) {
      if (!filterIndex.contains(element!.sortIdx)) {
        return false;
      } else if (!checkedList.contains(element.cells[currentColumn]!.value.toString())) {
        return false;
      } else {
        return true;
      }
    });
    widget.stateManager!.setFiltersNew(newData);
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(filterData);
    resetFilter(initial: true);

    // widget.stateManager.keyManager.
  }

  @override
  Widget build(BuildContext context) {
    print('Build');

    if (filterItems.isEmpty) {
      filterRows();
    }

    return SingleChildScrollView(
      child: Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.enter): EnterIntent(),
          LogicalKeySet(LogicalKeyboardKey.escape): EscapeIntent(),
        },
        child: Actions(
          actions: {EnterIntent: CallbackAction<EnterIntent>(onInvoke: (intent) => saveAndClose()), EscapeIntent: CallbackAction<EscapeIntent>(onInvoke: (intent) => Navigator.of(context).pop())},
          child: Focus(
            autofocus: true,
            child: Container(
              width: 600,
              height: 1000,
              color: Colors.grey[100],
              padding: const EdgeInsets.all(10),
              // margin: EdgeInsets.all(5),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      // if (widget.stateManager!.hasFilter) {
                      setState(() {
                        resetFilter();
                        widget.stateManager!.setFiltersNew({});
                        filterData = {};
                        controllerMap.forEach((key, value) {
                          value.text = '';
                        });
                      });
                      // }
                    },
                    child: const ListTile(
                      title: Text('Remove All Filters'),
                      leading: Icon(Icons.filter_alt),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      widget.stateManager!.hideColumn(widget.column!.key, true);
                      Navigator.of(context).pop();
                    },
                    child: const ListTile(
                      title: Text('Hide Column'),
                      leading: Icon(Icons.hide_image),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.stateManager!.showSetColumnsPopup(context);
                    },
                    child: const ListTile(
                      title: Text('Set Columns'),
                      leading: Icon(Icons.view_column_outlined),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        TextField(
                          controller: containsController,
                          focusNode: FocusNode(),
                          decoration: const InputDecoration(labelText: 'Contains'),
                          keyboardType: columnType.isNumber ? TextInputType.number : TextInputType.text,
                          onEditingComplete: () {
                            mainFocusNode.requestFocus();
                          },
                          onChanged: (value) {
                            setState(() {
                              filterRows();
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        if (columnType.isNumber)
                          TextField(
                            controller: greaterController,
                            decoration: const InputDecoration(labelText: 'Greater Than'),
                            keyboardType: TextInputType.number,
                            onEditingComplete: () {
                              mainFocusNode.requestFocus();
                            },
                            onChanged: (value) {
                              setState(() {
                                filterRows();
                              });
                            },
                          ),
                        const SizedBox(height: 10),
                        if (columnType.isNumber)
                          TextField(
                            controller: lesserController,
                            decoration: const InputDecoration(labelText: 'Less Than'),
                            keyboardType: TextInputType.number,
                            onEditingComplete: () {
                              mainFocusNode.requestFocus();
                            },
                            onChanged: (value) {
                              setState(() {
                                filterRows();
                              });
                            },
                          ),
                        if (columnType.isDate)
                          Container(
                            // width: 500,
                            // height: 300,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text('Ending After'),
                                Container(
                                  width: 100,
                                  child: TextField(
                                    controller: afterDayController,
                                    decoration: const InputDecoration(labelText: 'Days'),
                                    keyboardType: TextInputType.number,
                                    onEditingComplete: () {
                                      mainFocusNode.requestFocus();
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        // filter = value;
                                        filterRows();
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  child: TextField(
                                    controller: afterHourController,
                                    decoration: const InputDecoration(labelText: 'Hours'),
                                    keyboardType: TextInputType.number,
                                    onEditingComplete: () {
                                      mainFocusNode.requestFocus();
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        // filter = value;
                                        filterRows();
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  child: TextField(
                                    controller: afterMinController,
                                    decoration: const InputDecoration(labelText: 'Minutes'),
                                    keyboardType: TextInputType.number,
                                    onEditingComplete: () {
                                      mainFocusNode.requestFocus();
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        // filter = value;
                                        filterRows();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (columnType.isDate)
                          Container(
                            // width: 500,
                            // height: 300,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text('Ending Before'),
                                Container(
                                  width: 100,
                                  child: TextField(
                                    controller: beforeDayController,
                                    decoration: const InputDecoration(labelText: 'Days'),
                                    keyboardType: TextInputType.number,
                                    onEditingComplete: () {
                                      mainFocusNode.requestFocus();
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        // filter = value;
                                        filterRows();
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  child: TextField(
                                    controller: beforeHourController,
                                    decoration: const InputDecoration(labelText: 'Hours'),
                                    keyboardType: TextInputType.number,
                                    onEditingComplete: () {
                                      mainFocusNode.requestFocus();
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        // filter = value;
                                        filterRows();
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  child: TextField(
                                    controller: beforeMinController,
                                    decoration: const InputDecoration(labelText: 'Minutes'),
                                    keyboardType: TextInputType.number,
                                    onEditingComplete: () {
                                      mainFocusNode.requestFocus();
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        // filter = value;
                                        filterRows();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    height: 280,
                    color: Colors.white,
                    child: ListView.builder(
                      itemCount: filterItems.length,
                      itemBuilder: (context, index) => CheckboxListTile(
                        tristate: filterItems[index] == 'Select All' ? true : false,
                        title: Text(filterItems[index]),
                        value: filterItems[index] == 'Select All' ? getShowAllChecked() : checkedList.contains(filterItems[index]),
                        onChanged: (value) {
                          var title = filterItems[index];
                          if (title == 'Select All') {
                            setState(() {
                              // If Select All is in checkedLists
                              // Clear check List
                              if (checkedList.contains(title)) {
                                // then set as true
                                checkedList = [];
                              } else {
                                checkedList = [];
                                checkedList.addAll(filterItems);
                              }
                            });
                          } else {
                            setState(() {
                              print(value);
                              checked[title] = value!;
                              if (value && !checkedList.contains(title)) {
                                checkedList.add(title);
                              } else {
                                checkedList.remove(title);
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel')),
                      ElevatedButton(
                          onPressed: () {
                            saveAndClose();
                          },
                          child: const Text('Done')),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
