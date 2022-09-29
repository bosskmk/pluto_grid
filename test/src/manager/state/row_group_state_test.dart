// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../mock/shared_mocks.mocks.dart';

void main() {
  PlutoGridStateManager createStateManager({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
  }) {
    WidgetsFlutterBinding.ensureInitialized();

    final stateManager = PlutoGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: null,
      scroll: null,
    );

    stateManager.setEventManager(MockPlutoGridEventManager());
    stateManager.setLayout(const BoxConstraints());

    return stateManager;
  }

  group('No delegate', () {
    test('delegate 가 없으면 hasRowGroups 가 false 를 리턴 해야 한다.', () {
      final stateManager = createStateManager(columns: [], rows: []);

      expect(stateManager.hasRowGroups, false);
    });

    test('delegate 가 없으면 enabledRowGroups 가 false 를 리턴 해야 한다.', () {
      final stateManager = createStateManager(columns: [], rows: []);

      expect(stateManager.enabledRowGroups, false);
    });

    test('delegate 가 없으면 rowGroupDelegate 가 null 를 리턴 해야 한다.', () {
      final stateManager = createStateManager(columns: [], rows: []);

      expect(stateManager.rowGroupDelegate, null);
    });

    test('iterateMainRowGroup 는 5개의 행을 리턴해야 한다.', () {
      final rows = [
        PlutoRow(cells: {}),
        PlutoRow(cells: {}),
        PlutoRow(cells: {}),
        PlutoRow(cells: {}),
        PlutoRow(cells: {}),
      ];

      final stateManager = createStateManager(columns: [], rows: rows);

      expect(stateManager.iterateMainRowGroup.length, 5);
    });

    group('[그룹행(3 자식), 일반행, 일반행]', () {
      late PlutoGridStateManager stateManager;

      late PlutoRow groupedRow;

      late FilteredList<PlutoRow> children;

      late List<PlutoRow> rows;

      setUp(() {
        children = FilteredList(
          initialList: [
            PlutoRow(cells: {}),
            PlutoRow(cells: {}),
            PlutoRow(cells: {}),
          ],
        );

        groupedRow = PlutoRow(
          cells: {},
          type: PlutoRowType.group(children: children),
        );

        setParent(e) => e.setParent(groupedRow);

        children.forEach(setParent);

        rows = [
          groupedRow,
          PlutoRow(cells: {}),
          PlutoRow(cells: {}),
        ];

        stateManager = createStateManager(columns: [], rows: rows);
      });

      test('iterateMainRowGroup.length 는 3을 리턴해야 한다.', () {
        expect(stateManager.iterateMainRowGroup.length, 3);
      });

      test('iterateRowGroup.length 는 1을 리턴해야 한다.', () {
        expect(stateManager.iterateRowGroup.length, 1);
      });

      test('iterateRowAndGroup.length 는 6을 리턴해야 한다.', () {
        expect(stateManager.iterateRowAndGroup.length, 6);
      });

      test('iterateRow.length 는 5을 리턴해야 한다.', () {
        expect(stateManager.iterateRow.length, 5);
      });

      test('refRows 의 행은 isMainRow 가 true 를 리턴해야 한다.', () {
        final List<bool> result = [];

        addResult(e) => result.add(stateManager.isMainRow(e));

        stateManager.refRows.forEach(addResult);

        expect(result.length, 3);
        expect(result, [true, true, true]);
      });

      test('children 의 행은 isMainRow 가 false 를 리턴해야 한다.', () {
        final List<bool> result = [];

        addResult(e) => result.add(stateManager.isMainRow(e));

        children.forEach(addResult);

        expect(result.length, 3);
        expect(result, [false, false, false]);
      });

      test('refRows 의 행은 isNotMainGroupedRow 가 false 를 리턴해야 한다.', () {
        final List<bool> result = [];

        addResult(e) => result.add(stateManager.isNotMainGroupedRow(e));

        stateManager.refRows.forEach(addResult);

        expect(result.length, 3);
        expect(result, [false, false, false]);
      });

      test('children 의 행은 isNotMainGroupedRow 가 true 를 리턴해야 한다.', () {
        final List<bool> result = [];

        addResult(e) => result.add(stateManager.isNotMainGroupedRow(e));

        children.forEach(addResult);

        expect(result.length, 3);
        expect(result, [true, true, true]);
      });

      test('children 의 행은 isExpandedGroupedRow 가 false 를 리턴해야 한다.', () {
        final List<bool> result = [];

        addResult(e) => result.add(stateManager.isExpandedGroupedRow(e));

        children.forEach(addResult);

        expect(result.length, 3);
        expect(result, [false, false, false]);
      });

      test(
        'groupedRow 의 expanded 를 true 로 설정하면, '
        'isExpandedGroupedRow 가 true 를 리턴해야 한다.',
        () {
          groupedRow.type.group.setExpanded(true);

          expect(stateManager.isExpandedGroupedRow(groupedRow), true);
        },
      );

      test(
        'groupedRow 의 expanded 를 false 로 설정하면, '
        'isExpandedGroupedRow 가 false 를 리턴해야 한다.',
        () {
          groupedRow.type.group.setExpanded(false);

          expect(stateManager.isExpandedGroupedRow(groupedRow), false);
        },
      );
    });
  });

  group('2개의 컬럼으로 그룹핑 - PlutoRowGroupByColumnDelegate.', () {
    late List<PlutoColumn> columns;

    late List<PlutoRow> rows;

    late PlutoGridStateManager stateManager;

    setUp(() {
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
          type: PlutoColumnType.text(),
        ),
      ];

      rows = [
        PlutoRow(cells: {
          'column1': PlutoCell(value: 'A'),
          'column2': PlutoCell(value: '1'),
          'column3': PlutoCell(value: '001'),
        }),
        PlutoRow(cells: {
          'column1': PlutoCell(value: 'A'),
          'column2': PlutoCell(value: '2'),
          'column3': PlutoCell(value: '002'),
        }),
        PlutoRow(cells: {
          'column1': PlutoCell(value: 'B'),
          'column2': PlutoCell(value: '1'),
          'column3': PlutoCell(value: '003'),
        }),
        PlutoRow(cells: {
          'column1': PlutoCell(value: 'B'),
          'column2': PlutoCell(value: '1'),
          'column3': PlutoCell(value: '004'),
        }),
        PlutoRow(cells: {
          'column1': PlutoCell(value: 'B'),
          'column2': PlutoCell(value: '2'),
          'column3': PlutoCell(value: '005'),
        }),
      ];

      stateManager = createStateManager(columns: columns, rows: rows);

      stateManager.setRowGroup(PlutoRowGroupByColumnDelegate(columns: [
        columns[0],
        columns[1],
      ]));
    });

    test('hasRowGroups 이 true 를 리턴해야 한다.', () {
      expect(stateManager.hasRowGroups, true);
    });

    test('enabledRowGroups 이 true 를 리턴해야 한다.', () {
      expect(stateManager.enabledRowGroups, true);
    });

    test('rowGroupDelegate 는 PlutoRowGroupByColumnDelegate 이어야 한다.', () {
      expect(
        stateManager.rowGroupDelegate is PlutoRowGroupByColumnDelegate,
        true,
      );
    });

    test('iterateMainRowGroup 가 2개의 행을 리턴해야 한다.', () {
      final mainRowGroup = stateManager.iterateMainRowGroup.toList();

      expect(mainRowGroup.length, 2);
    });

    test('iterateRowGroup 가 6개의 행을 리턴해야 한다.', () {
      final mainRowGroup = stateManager.iterateRowGroup.toList();

      expect(mainRowGroup.length, 6);
    });

    test('iterateRowAndGroup 가 11개의 행을 리턴해야 한다.', () {
      final mainRowGroup = stateManager.iterateRowAndGroup.toList();

      expect(mainRowGroup.length, 11);
    });

    test('iterateRow 가 5개의 행을 리턴해야 한다.', () {
      final mainRowGroup = stateManager.iterateRow.toList();

      expect(mainRowGroup.length, 5);
    });

    test('첫번째 행을 expand 하면 refRows 는 4개의 행을 리턴해야 한다.', () {
      final firstRowGroup = stateManager.refRows.first;

      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);

      expect(firstRowGroup.type.group.expanded, true);
      expect(stateManager.refRows.length, 4);
    });

    test('첫번째 행을 expand 하고 다시 collapse 하면 refRows 는 2개의 행을 리턴해야 한다.', () {
      final firstRowGroup = stateManager.refRows.first;

      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);

      expect(firstRowGroup.type.group.expanded, true);
      expect(stateManager.refRows.length, 4);

      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);

      expect(firstRowGroup.type.group.expanded, false);
      expect(stateManager.refRows.length, 2);
    });

    test(
      '첫번째 행을 expand 하고 펼처진 두번째 행을 expand 하면, '
      'refRows 는 5개의 행을 리턴해야 한다.',
      () {
        final firstRowGroup = stateManager.refRows.first;
        final firstRowGroupFirstChild = firstRowGroup.type.group.children.first;

        stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);
        stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroupFirstChild);

        expect(firstRowGroup.type.group.expanded, true);
        expect(firstRowGroupFirstChild.type.group.expanded, true);
        expect(stateManager.refRows.length, 5);
      },
    );

    test(
      '첫번째 행과 그 첫번째 자식을 expand 하고 첫번째 행을 다시 collapse 하면, '
      'refRows 는 2개의 행을 리턴해야 한다.'
      '그리고 다시 첫번째 행을 expand 하면 이미 펼쳐져 있던 첫번째 자식은 함께 펼쳐져야 한다.',
      () {
        final firstRowGroup = stateManager.refRows.first;
        final firstRowGroupFirstChild = firstRowGroup.type.group.children.first;

        stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);
        stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroupFirstChild);

        expect(firstRowGroup.type.group.expanded, true);
        expect(firstRowGroupFirstChild.type.group.expanded, true);
        expect(stateManager.refRows.length, 5);

        stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);
        expect(firstRowGroup.type.group.expanded, false);
        expect(stateManager.refRows.length, 2);

        stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);
        expect(firstRowGroup.type.group.expanded, true);
        expect(stateManager.refRows.length, 5);
      },
    );

    test('refRows 가 설정한 2개의 컬럼으로 그룹핑 되어야 한다.', () {
      final firstGroupField = columns[0].field;

      expect(stateManager.refRows.length, 2);

      expect(stateManager.refRows[0].type.isGroup, true);
      expect(stateManager.refRows[0].cells[firstGroupField]!.value, 'A');

      expect(stateManager.refRows[1].type.isGroup, true);
      expect(stateManager.refRows[1].cells[firstGroupField]!.value, 'B');
    });

    group('첫번째 그룹.', () {
      late FilteredList<PlutoRow> aGroupChildren;

      setUp(() {
        aGroupChildren = stateManager.refRows[0].type.group.children;
      });

      test('자식들이 두번째 컬럼으로 그룹핑 되어야 한다.', () {
        final secondGroupField = columns[1].field;

        expect(aGroupChildren.length, 2);

        expect(aGroupChildren[0].type.isGroup, true);
        expect(aGroupChildren[0].cells[secondGroupField]!.value, '1');

        expect(aGroupChildren[1].type.isGroup, true);
        expect(aGroupChildren[1].cells[secondGroupField]!.value, '2');
      });

      test('자식들은 각 1개의 자식을 가지고 있어야 한다.', () {
        final normalColumnField = columns[2].field;

        final aGroupFirstChildren = aGroupChildren[0].type.group.children;
        expect(aGroupFirstChildren.length, 1);
        expect(aGroupFirstChildren[0].type.isNormal, true);
        expect(aGroupFirstChildren[0].cells[normalColumnField]!.value, '001');

        final aGroupSecondChildren = aGroupChildren[1].type.group.children;
        expect(aGroupSecondChildren.length, 1);
        expect(aGroupSecondChildren[0].type.isNormal, true);
        expect(
          aGroupSecondChildren[0].cells[normalColumnField]!.value,
          '002',
        );
      });
    });

    group('두번째 그룹.', () {
      late FilteredList<PlutoRow> bGroupChildren;

      setUp(() {
        bGroupChildren = stateManager.refRows[1].type.group.children;
      });

      test('자식들이 두번째 컬럼으로 그룹핑 되어야 한다.', () {
        final secondGroupField = columns[1].field;

        expect(bGroupChildren.length, 2);

        expect(bGroupChildren[0].type.isGroup, true);
        expect(bGroupChildren[0].cells[secondGroupField]!.value, '1');

        expect(bGroupChildren[1].type.isGroup, true);
        expect(bGroupChildren[1].cells[secondGroupField]!.value, '2');
      });

      test('자식들은 각 2개, 1개의 자식을 가지고 있어야 한다.', () {
        final normalColumnField = columns[2].field;

        final bGroupFirstChildren = bGroupChildren[0].type.group.children;
        expect(bGroupFirstChildren.length, 2);
        expect(bGroupFirstChildren[0].type.isNormal, true);
        expect(bGroupFirstChildren[0].cells[normalColumnField]!.value, '003');
        expect(bGroupFirstChildren[1].type.isNormal, true);
        expect(bGroupFirstChildren[1].cells[normalColumnField]!.value, '004');

        final bGroupSecondChildren = bGroupChildren[1].type.group.children;
        expect(bGroupSecondChildren.length, 1);
        expect(bGroupSecondChildren[0].type.isNormal, true);
        expect(
          bGroupSecondChildren[0].cells[normalColumnField]!.value,
          '005',
        );
      });
    });

    test('column1 을 A 값으로 필터링 하면 1개의 행이 리턴 되어야 한다.', () {
      stateManager.setFilter((row) => row.cells['column1']!.value == 'A');

      expect(stateManager.refRows.length, 1);
    });

    test('첫번째 행을 펼친 후 column1 을 A 값으로 필터링 하면 3개의 행이 리턴 되어야 한다.', () {
      final firstRowGroup = stateManager.refRows.first;

      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);

      stateManager.setFilter((row) => row.cells['column1']!.value == 'A');

      // 첫번째 행 + 첫번째 행의 2개의 자식 = 3개
      expect(stateManager.refRows.length, 3);
    });

    test('두개의 행을 모두 펼친 후 column2 을 1 값으로 필터링 하면 4개의 행이 리턴 되어야 한다.', () {
      final firstRowGroup = stateManager.refRows[0];
      final secondRowGroup = stateManager.refRows[1];

      stateManager.toggleExpandedRowGroup(rowGroup: firstRowGroup);
      stateManager.toggleExpandedRowGroup(rowGroup: secondRowGroup);
      expect(stateManager.refRows.length, 6);

      stateManager.setFilter((row) => row.cells['column2']!.value == '1');

      expect(stateManager.refRows.length, 4);
    });

    test('column1 을 descending 정렬 하면 두개의 행의 위치가 바뀌어야 한다.', () {
      expect(stateManager.refRows[0].cells['column1']!.value, 'A');
      expect(stateManager.refRows[1].cells['column1']!.value, 'B');

      // Ascending
      stateManager.toggleSortColumn(columns[0]);
      // Descending
      stateManager.toggleSortColumn(columns[0]);

      expect(stateManager.refRows[0].cells['column1']!.value, 'B');
      expect(stateManager.refRows[1].cells['column1']!.value, 'A');
    });

    test(
      '두번째 행을 모두 펼친 후 column3 를 descending 정렬 하면, '
      '두번째 행의 2개의 자식의 위치가 바뀌어야 한다.',
      () {
        final secondRowGroup = stateManager.refRows[1];

        stateManager.toggleExpandedRowGroup(rowGroup: secondRowGroup);

        final secondRowGroupFirstChild = secondRowGroup.type.group.children[0];
        stateManager.toggleExpandedRowGroup(rowGroup: secondRowGroupFirstChild);

        final secondRowGroupSecondChild = secondRowGroup.type.group.children[1];
        stateManager.toggleExpandedRowGroup(
          rowGroup: secondRowGroupSecondChild,
        );

        {
          final fistChild = secondRowGroupFirstChild.type.group.children[0];
          expect(fistChild.cells['column3']!.value, '003');

          final secondChild = secondRowGroupFirstChild.type.group.children[1];
          expect(secondChild.cells['column3']!.value, '004');
        }

        // Ascending
        stateManager.toggleSortColumn(columns[2]);
        // Descending
        stateManager.toggleSortColumn(columns[2]);

        {
          final fistChild = secondRowGroupFirstChild.type.group.children[0];
          expect(fistChild.cells['column3']!.value, '004');

          final secondChild = secondRowGroupFirstChild.type.group.children[1];
          expect(secondChild.cells['column3']!.value, '003');
        }
      },
    );

    test('첫번째 행에 column2 의 값이 3인 행을 추가 하면 첫번째 행의 자식은 3개가 되어야 한다.', () {
      final rowToAdd = PlutoRow(cells: {
        'column1': PlutoCell(value: 'A'),
        'column2': PlutoCell(value: '3'),
        'column3': PlutoCell(value: '006'),
      });

      expect(stateManager.refRows.first.type.group.children.length, 2);

      stateManager.insertRows(0, [rowToAdd]);

      expect(stateManager.refRows.first.type.group.children.length, 3);
    });

    test('첫번째 행에 column2 의 값이 3인 행을 추가 하면 추가 된 자식의 parent 가 설정 되어야 한다.', () {
      final rowToAdd = PlutoRow(cells: {
        'column1': PlutoCell(value: 'A'),
        'column2': PlutoCell(value: '3'),
        'column3': PlutoCell(value: '006'),
      });

      stateManager.insertRows(0, [rowToAdd]);

      expect(rowToAdd.parent?.cells['column2']!.value, '3');
      expect(rowToAdd.parent?.parent, stateManager.refRows.first);
    });

    test(
      '정렬 된 상태에서 첫번째 행에 column2 의 값이 3인 행을 추가 하면, '
      '추가 된 자식의 parent 가 설정 되어야 한다.',
      () {
        final rowToAdd = PlutoRow(cells: {
          'column1': PlutoCell(value: 'A'),
          'column2': PlutoCell(value: '3'),
          'column3': PlutoCell(value: '006'),
        });

        stateManager.toggleSortColumn(columns.first);

        stateManager.insertRows(0, [rowToAdd]);

        expect(rowToAdd.parent?.cells['column2']!.value, '3');
        expect(rowToAdd.parent?.parent, stateManager.refRows.first);
      },
    );

    test(
      'prependRows 로 column2 의 값이 3인 행을 추가 하면, '
      '추가 된 자식의 parent 가 설정 되어야 한다.',
      () {
        final rowToAdd = PlutoRow(cells: {
          'column1': PlutoCell(value: 'A'),
          'column2': PlutoCell(value: '3'),
          'column3': PlutoCell(value: '006'),
        });

        stateManager.toggleSortColumn(columns.first);

        stateManager.prependRows([rowToAdd]);

        expect(rowToAdd.parent?.cells['column2']!.value, '3');
        expect(rowToAdd.parent?.parent, stateManager.refRows.first);
      },
    );

    test(
      'appendRows 로 column2 의 값이 3인 행을 추가 하면, '
      '추가 된 자식의 parent 가 설정 되어야 한다.',
      () {
        final rowToAdd = PlutoRow(cells: {
          'column1': PlutoCell(value: 'A'),
          'column2': PlutoCell(value: '3'),
          'column3': PlutoCell(value: '006'),
        });

        stateManager.toggleSortColumn(columns.first);

        stateManager.appendRows([rowToAdd]);

        expect(rowToAdd.parent?.cells['column2']!.value, '3');
        expect(rowToAdd.parent?.parent, stateManager.refRows.first);
      },
    );

    test('첫번째 행을 삭제 하면 그 자식들도 모두 삭제 되어야 한다.', () {
      final firstRowGroup = stateManager.refRows.first;

      expect(stateManager.iterateRowAndGroup.length, 11);

      stateManager.removeRows([firstRowGroup]);

      expect(stateManager.iterateRowAndGroup.length, 6);
    });

    test('column1 을 삭제 하면 column2 로 다시 그룹핑 되어야 한다.', () {
      final firstColumn = stateManager.refColumns.first;

      stateManager.removeColumns([firstColumn]);

      expect(stateManager.refRows.length, 2);

      {
        final rowGroup = stateManager.refRows[0];
        expect(rowGroup.cells['column2']!.value, '1');
        expect(rowGroup.type.group.children.length, 3);
      }

      {
        final rowGroup = stateManager.refRows[1];
        expect(rowGroup.cells['column2']!.value, '2');
        expect(rowGroup.type.group.children.length, 2);
      }
    });

    test('column1 을 숨기면 하면 column2 로 다시 그룹핑 되어야 한다.', () {
      final firstColumn = stateManager.refColumns.first;

      stateManager.hideColumn(firstColumn, true);

      expect(stateManager.refRows.length, 2);

      {
        final rowGroup = stateManager.refRows[0];
        expect(rowGroup.cells['column2']!.value, '1');
        expect(rowGroup.type.group.children.length, 3);
      }

      {
        final rowGroup = stateManager.refRows[1];
        expect(rowGroup.cells['column2']!.value, '2');
        expect(rowGroup.type.group.children.length, 2);
      }
    });

    test('column1 을 숨기고 다시 해제 하면 column1 로 다시 그룹핑 되어야 한다.', () {
      final firstColumn = stateManager.refColumns.first;

      stateManager.hideColumn(firstColumn, true);

      expect(stateManager.refRows.length, 2);

      {
        final rowGroup = stateManager.refRows[0];
        expect(rowGroup.cells['column2']!.value, '1');
        expect(rowGroup.type.group.children.length, 3);
      }

      {
        final rowGroup = stateManager.refRows[1];
        expect(rowGroup.cells['column2']!.value, '2');
        expect(rowGroup.type.group.children.length, 2);
      }

      stateManager.hideColumn(firstColumn, false);

      {
        final rowGroup = stateManager.refRows[0];
        expect(rowGroup.cells['column1']!.value, 'A');
        expect(rowGroup.type.group.children.length, 2);
      }

      {
        final rowGroup = stateManager.refRows[1];
        expect(rowGroup.cells['column1']!.value, 'B');
        expect(rowGroup.type.group.children.length, 2);
      }
    });
  });

  /// G100
  ///   - G110
  ///     - R111
  ///     - R112
  ///   - R120
  ///   - R130
  /// G200
  ///   - R210
  ///   - G220
  ///     - R221
  ///     - R222
  group('최대 3 뎁스로 그룹화 - PlutoRowGroupTreeDelegate', () {
    late List<PlutoColumn> columns;

    late List<PlutoRow> rows;

    late PlutoGridStateManager stateManager;

    Map<String, PlutoCell> createCell(String value) {
      return {
        'column1': PlutoCell(value: value),
        'column2': PlutoCell(value: ''),
        'column3': PlutoCell(value: ''),
        'column4': PlutoCell(value: ''),
        'column5': PlutoCell(value: ''),
      };
    }

    setUp(() {
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
          type: PlutoColumnType.text(),
        ),
        PlutoColumn(
          title: 'column4',
          field: 'column4',
          type: PlutoColumnType.text(),
        ),
        PlutoColumn(
          title: 'column5',
          field: 'column5',
          type: PlutoColumnType.text(),
        ),
      ];

      rows = [
        PlutoRow(
          cells: createCell('G100'),
          type: PlutoRowType.group(
            children: FilteredList(
              initialList: [
                PlutoRow(
                  cells: createCell('G110'),
                  type: PlutoRowType.group(
                    children: FilteredList(
                      initialList: [
                        PlutoRow(cells: createCell('R111')),
                        PlutoRow(cells: createCell('R112')),
                      ],
                    ),
                  ),
                ),
                PlutoRow(cells: createCell('R120')),
                PlutoRow(cells: createCell('R130')),
              ],
            ),
          ),
        ),
        PlutoRow(
          cells: createCell('G200'),
          type: PlutoRowType.group(
            children: FilteredList(
              initialList: [
                PlutoRow(cells: createCell('R210')),
                PlutoRow(
                  cells: createCell('G220'),
                  type: PlutoRowType.group(
                    children: FilteredList(
                      initialList: [
                        PlutoRow(cells: createCell('R221')),
                        PlutoRow(cells: createCell('R222')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ];

      stateManager = createStateManager(columns: columns, rows: rows);

      stateManager.setRowGroup(
        PlutoRowGroupTreeDelegate(
          showExpandableIcon: (cell) =>
              stateManager.columns.length > cell.row.depth &&
              stateManager.columns[cell.row.depth].field == cell.column.field &&
              cell.row.type.isGroup,
          showText: (cell) => cell.row.type.isNormal,
        ),
      );
    });

    test('hasRowGroups 가 true 를 리턴해야 한다.', () {
      expect(stateManager.hasRowGroups, true);
    });

    test('enabledRowGroups 가 true 를 리턴해야 한다.', () {
      expect(stateManager.enabledRowGroups, true);
    });

    test('rowGroupDelegate 가 PlutoRowGroupTreeDelegate 이어야 한다.', () {
      expect(stateManager.rowGroupDelegate is PlutoRowGroupTreeDelegate, true);
    });

    test('iterateMainRowGroup 가 2개 행을 리턴해야 한다.', () {
      expect(stateManager.iterateMainRowGroup.length, 2);
    });

    test('iterateRowGroup 가 4개 행을 리턴해야 한다.', () {
      expect(stateManager.iterateRowGroup.length, 4);
    });

    test('iterateRowAndGroup 가 11개 행을 리턴해야 한다.', () {
      expect(stateManager.iterateRowAndGroup.length, 11);
    });

    test('iterateRow 가 7개 행을 리턴해야 한다.', () {
      expect(stateManager.iterateRow.length, 7);
    });

    test('refRows 의 두개의 행이 isMainRow true 를 반환해야 한다.', () {
      expect(stateManager.refRows.length, 2);
      expect(stateManager.isMainRow(stateManager.refRows[0]), true);
      expect(stateManager.isMainRow(stateManager.refRows[1]), true);
    });

    test('계층에 맞게 parent 가 설정 되어야 한다.', () {
      final G100 = stateManager.refRows[0];
      final G100_CHILDREN = G100.type.group.children;
      expect(G100.parent, null);
      expect(G100_CHILDREN.length, 3);
      expect(G100_CHILDREN.length, 3);
      expect(G100_CHILDREN[0].parent, G100);
      expect(G100_CHILDREN[1].parent, G100);
      expect(G100_CHILDREN[2].parent, G100);

      final G110 = G100_CHILDREN[0];
      final G110_CHILDREN = G110.type.group.children;
      expect(G110_CHILDREN.length, 2);
      expect(G110_CHILDREN[0].parent, G110);
      expect(G110_CHILDREN[0].parent?.parent, G100);
      expect(G110_CHILDREN[1].parent, G110);
      expect(G110_CHILDREN[1].parent?.parent, G100);

      final G200 = stateManager.refRows[1];
      expect(G200.parent, null);
      expect(G200.type.group.children.length, 2);
      expect(G200.type.group.children[0].parent, G200);
      expect(G200.type.group.children[1].parent, G200);

      final G220 = G200.type.group.children[1];
      final G220_CHILDREN = G220.type.group.children;
      expect(G220_CHILDREN.length, 2);
      expect(G220_CHILDREN[0].parent, G220);
      expect(G220_CHILDREN[0].parent?.parent, G200);
      expect(G220_CHILDREN[1].parent, G220);
      expect(G220_CHILDREN[1].parent?.parent, G200);
    });
  });
}
