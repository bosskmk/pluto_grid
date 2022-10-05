// ignore_for_file: non_constant_identifier_names

import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  PlutoRow createRow(
    String value1,
    String value2,
    String value3,
    String value4,
    String value5,
    List<PlutoColumn> columns,
  ) {
    final Map<String, PlutoCell> cells = {};

    final row = PlutoRow(cells: cells);

    cells['column1'] = PlutoCell(value: value1)
      ..setRow(row)
      ..setColumn(columns[0]);
    cells['column2'] = PlutoCell(value: value2)
      ..setRow(row)
      ..setColumn(columns[1]);
    cells['column3'] = PlutoCell(value: value3)
      ..setRow(row)
      ..setColumn(columns[2]);
    cells['column4'] = PlutoCell(value: value4)
      ..setRow(row)
      ..setColumn(columns[3]);
    cells['column5'] = PlutoCell(value: value5)
      ..setRow(row)
      ..setColumn(columns[4]);

    return row;
  }

  /// (G) A-1-11
  /// (R)      -A111-01
  /// (G)    -12
  /// (R)      -A121-02
  /// (R)      -A122-03
  /// (G)  -2-21
  /// (R)      -A211-04
  /// (G) B-1-11
  /// (R)      -B111-05
  /// (G)    -12
  /// (R)      -B112-06
  /// (G)  -2-21
  /// (R)      -B211-07
  /// (G)  -3-31
  /// (R)      -B311-08
  /// (G)  -4-41
  /// (R)      -B411-09
  /// (G)    -42
  /// (R)      -B412-10
  group('PlutoRowGroupByColumnDelegate. 3개 컬럼으로 그룹핑.', () {
    late PlutoRowGroupByColumnDelegate delegate;

    late List<PlutoColumn> columns;

    late List<PlutoRow> rows;

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
        createRow('A', '1', '11', 'A111', '01', columns),
        createRow('A', '1', '12', 'A121', '02', columns),
        createRow('A', '1', '12', 'A122', '03', columns),
        createRow('A', '2', '21', 'A211', '04', columns),
        createRow('B', '1', '11', 'B111', '05', columns),
        createRow('B', '1', '12', 'B112', '06', columns),
        createRow('B', '2', '21', 'B211', '07', columns),
        createRow('B', '3', '31', 'B311', '08', columns),
        createRow('B', '4', '41', 'B411', '09', columns),
        createRow('B', '4', '42', 'B412', '10', columns),
      ];

      delegate = PlutoRowGroupByColumnDelegate(columns: [
        columns[0],
        columns[1],
        columns[2],
      ]);
    });

    test('type 이 byColumn 을 리턴해야 한다.', () {
      expect(delegate.type, PlutoRowGroupDelegateType.byColumn);
    });

    test('enabled 가 true 를 리턴해야 한다.', () {
      expect(delegate.enabled, true);
    });

    test('visibleColumns.length 가 3 이어야 한다.', () {
      expect(delegate.visibleColumns.length, 3);
    });

    test('visibleColumns 1개 hide 하면 length 가 2 를 리턴해야 한다.', () {
      delegate.visibleColumns.first.hide = true;
      expect(delegate.enabled, true);
      expect(delegate.visibleColumns.length, 2);
    });

    test(
      'visibleColumns 를 모두 hide 하면, '
      'length 가 0 을 리턴하고 enabled 가 false 를 리턴해야 한다.',
      () {
        setHide(c) => c.hide = true;
        delegate.visibleColumns.forEach(setHide);
        expect(delegate.enabled, false);
        expect(delegate.visibleColumns.length, 0);
      },
    );

    group('toGroup', () {
      test('2개의 그룹행을 리턴해야 한다.', () {
        final grouped = delegate.toGroup(rows: rows);

        expect(grouped.length, 2);
      });

      test('첫번째 그룹의 자식들의 길이와 parent 가 상태에 맞게 설정 되어야 한다.', () {
        /// (G) A-1-11
        /// (R)      -A111-01
        /// (G)    -12
        /// (R)      -A121-02
        /// (R)      -A122-03
        /// (G)  -2-21
        /// (R)      -A211-04
        final grouped = delegate.toGroup(rows: rows);
        final A = grouped.first;
        final A_CHILDREN = A.type.group.children;
        expect(A.parent, null);
        expect(A_CHILDREN.length, 2);
        expect(A_CHILDREN[0].parent, A);
        expect(A_CHILDREN[1].parent, A);

        final A_1 = A_CHILDREN[0];
        final A_1_CHILDREN = A_1.type.group.children;
        expect(A_1_CHILDREN.length, 2);
        expect(A_1_CHILDREN[0].parent, A_1);
        expect(A_1_CHILDREN[1].parent, A_1);

        final A_1_11 = A_1_CHILDREN[0];
        expect(A_1_11.type.group.children.length, 1);
        final A111_01 = A_1_11.type.group.children[0];
        expect(A111_01.parent, A_1_11);
        expect(A111_01.type.isNormal, true);

        final A_1_12 = A_1_CHILDREN[1];
        expect(A_1_12.type.group.children.length, 2);
        final A121_02 = A_1_12.type.group.children[0];
        expect(A121_02.parent, A_1_12);
        expect(A121_02.type.isNormal, true);
        final A122_03 = A_1_12.type.group.children[1];
        expect(A122_03.parent, A_1_12);
        expect(A122_03.type.isNormal, true);

        final A_2 = A_CHILDREN[1];
        final A_2_CHILDREN = A_2.type.group.children;
        expect(A_2_CHILDREN.length, 1);

        final A_2_21 = A_2_CHILDREN[0];
        final A_2_21_CHILDREN = A_2_21.type.group.children;
        expect(A_2_21_CHILDREN.length, 1);
        final A2111_04 = A_2_21_CHILDREN[0];
        expect(A2111_04.parent, A_2_21);
        expect(A2111_04.type.isNormal, true);
      });
    });
  });
}
