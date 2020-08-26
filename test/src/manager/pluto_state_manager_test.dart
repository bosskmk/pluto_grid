import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  group('columns', () {
    testWidgets('columnIndexes - columns 에 맞는 index list 가 리턴 되어야 한다.',
        (WidgetTester tester) async {
      // given
      PlutoStateManager stateManager = PlutoStateManager(
        columns: [
          PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
          PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
          PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        ],
        rows: null,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final List<int> result = stateManager.columnIndexes;

      // then
      expect(result.length, 3);
      expect(result, [0, 1, 2]);
    });

    testWidgets('columnIndexesForShowFixed - 고정 컬럼 순서에 맞게 리턴 되어야 한다.',
        (WidgetTester tester) async {
      // given
      PlutoStateManager stateManager = PlutoStateManager(
        columns: [
          PlutoColumn(
            title: '',
            field: '',
            type: PlutoColumnType.text(),
            fixed: PlutoColumnFixed.Right,
          ),
          PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
          PlutoColumn(
            title: '',
            field: '',
            type: PlutoColumnType.text(),
            fixed: PlutoColumnFixed.Left,
          ),
        ],
        rows: null,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final List<int> result = stateManager.columnIndexesForShowFixed;

      // then
      expect(result.length, 3);
      expect(result, [2, 1, 0]);
    });

    testWidgets('columnsWidth - 컬럼 넓이 합계를 리턴 해야 한다.',
        (WidgetTester tester) async {
      // given
      PlutoStateManager stateManager = PlutoStateManager(
        columns: [
          PlutoColumn(
            title: '',
            field: '',
            type: PlutoColumnType.text(),
            width: 150,
          ),
          PlutoColumn(
            title: '',
            field: '',
            type: PlutoColumnType.text(),
            width: 200,
          ),
          PlutoColumn(
            title: '',
            field: '',
            type: PlutoColumnType.text(),
            width: 250,
          ),
        ],
        rows: null,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final double result = stateManager.columnsWidth;

      // then
      expect(result, 600);
    });

    testWidgets('leftFixedColumns - 왼쪽 고정 컬럼 리스트만 리턴 되어야 한다.',
        (WidgetTester tester) async {
      // given
      PlutoStateManager stateManager = PlutoStateManager(
        columns: [
          PlutoColumn(
            title: 'left1',
            field: '',
            type: PlutoColumnType.text(),
            fixed: PlutoColumnFixed.Left,
          ),
          PlutoColumn(title: 'body', field: '', type: PlutoColumnType.text()),
          PlutoColumn(
            title: 'left2',
            field: '',
            type: PlutoColumnType.text(),
            fixed: PlutoColumnFixed.Left,
          ),
        ],
        rows: null,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final List<PlutoColumn> result = stateManager.leftFixedColumns;

      // then
      expect(result.length, 2);
      expect(result[0].title, 'left1');
      expect(result[1].title, 'left2');
    });

    testWidgets('leftFixedColumnIndexes - 왼쪽 고정 컬럼 인덱스 리스트만 리턴 되어야 한다.',
        (WidgetTester tester) async {
      // given
      PlutoStateManager stateManager = PlutoStateManager(
        columns: [
          PlutoColumn(
            title: 'right1',
            field: '',
            type: PlutoColumnType.text(),
            fixed: PlutoColumnFixed.Right,
          ),
          PlutoColumn(title: 'body', field: '', type: PlutoColumnType.text()),
          PlutoColumn(
            title: 'left2',
            field: '',
            type: PlutoColumnType.text(),
            fixed: PlutoColumnFixed.Left,
          ),
        ],
        rows: null,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final List<int> result = stateManager.leftFixedColumnIndexes;

      // then
      expect(result.length, 1);
      expect(result[0], 2);
    });

    testWidgets('leftFixedColumnsWidth - 왼쪽 고정 컬럼 넓이 합계를 리턴해야 한다.',
        (WidgetTester tester) async {
      // given
      PlutoStateManager stateManager = PlutoStateManager(
        columns: [
          PlutoColumn(
            title: 'right1',
            field: '',
            type: PlutoColumnType.text(),
            fixed: PlutoColumnFixed.Left,
            width: 150,
          ),
          PlutoColumn(
            title: 'body',
            field: '',
            type: PlutoColumnType.text(),
            width: 150,
          ),
          PlutoColumn(
            title: 'left2',
            field: '',
            type: PlutoColumnType.text(),
            fixed: PlutoColumnFixed.Left,
            width: 150,
          ),
        ],
        rows: null,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final double result = stateManager.leftFixedColumnsWidth;

      // then
      expect(result, 300);
    });

    testWidgets('rightFixedColumns - 오른쪽 고정 컬럼 리스트만 리턴 되어야 한다.',
        (WidgetTester tester) async {
      // given
      PlutoStateManager stateManager = PlutoStateManager(
        columns: [
          PlutoColumn(
            title: 'left1',
            field: '',
            type: PlutoColumnType.text(),
            fixed: PlutoColumnFixed.Left,
          ),
          PlutoColumn(title: 'body', field: '', type: PlutoColumnType.text()),
          PlutoColumn(
            title: 'right1',
            field: '',
            type: PlutoColumnType.text(),
            fixed: PlutoColumnFixed.Right,
          ),
        ],
        rows: null,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final List<PlutoColumn> result = stateManager.rightFixedColumns;

      // then
      expect(result.length, 1);
      expect(result[0].title, 'right1');
    });

    testWidgets('rightFixedColumnIndexes - 오른쪽 고정 컬럼 인덱스 리스트만 리턴 되어야 한다.',
        (WidgetTester tester) async {
      // given
      PlutoStateManager stateManager = PlutoStateManager(
        columns: [
          PlutoColumn(
            title: 'right1',
            field: '',
            type: PlutoColumnType.text(),
            fixed: PlutoColumnFixed.Right,
          ),
          PlutoColumn(title: 'body', field: '', type: PlutoColumnType.text()),
          PlutoColumn(
            title: 'right2',
            field: '',
            type: PlutoColumnType.text(),
            fixed: PlutoColumnFixed.Right,
          ),
        ],
        rows: null,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final List<int> result = stateManager.rightFixedColumnIndexes;

      // then
      expect(result.length, 2);
      expect(result[0], 0);
      expect(result[1], 2);
    });

    testWidgets('rightFixedColumnsWidth - 오른쪽 고정 컬럼 넓이 합계를 리턴해야 한다.',
        (WidgetTester tester) async {
      // given
      PlutoStateManager stateManager = PlutoStateManager(
        columns: [
          PlutoColumn(
            title: 'right1',
            field: '',
            type: PlutoColumnType.text(),
            fixed: PlutoColumnFixed.Right,
            width: 120,
          ),
          PlutoColumn(
            title: 'right2',
            field: '',
            type: PlutoColumnType.text(),
            fixed: PlutoColumnFixed.Right,
            width: 120,
          ),
          PlutoColumn(
            title: 'body',
            field: '',
            type: PlutoColumnType.text(),
            width: 100,
          ),
          PlutoColumn(
            title: 'left1',
            field: '',
            type: PlutoColumnType.text(),
            fixed: PlutoColumnFixed.Left,
            width: 120,
          ),
        ],
        rows: null,
        gridFocusNode: null,
        scroll: null,
      );

      // when
      final double result = stateManager.rightFixedColumnsWidth;

      // then
      expect(result, 240);
    });
  });
}
