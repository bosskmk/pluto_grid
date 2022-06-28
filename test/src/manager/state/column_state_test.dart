import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/mock_on_change_listener.dart';
import 'column_state_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<PlutoGridScrollController>(returnNullOnMissingStub: true),
  MockSpec<ScrollController>(returnNullOnMissingStub: true),
  MockSpec<ScrollPosition>(returnNullOnMissingStub: true),
  MockSpec<PlutoGridEventManager>(returnNullOnMissingStub: true),
])
void main() {
  final MockPlutoGridScrollController scroll = MockPlutoGridScrollController();
  final MockScrollController scrollController = MockScrollController();
  final MockScrollPosition scrollPosition = MockScrollPosition();
  final MockPlutoGridEventManager eventManager = MockPlutoGridEventManager();

  when(scroll.maxScrollHorizontal).thenReturn(0);
  when(scroll.bodyRowsHorizontal).thenReturn(scrollController);
  when(scrollController.hasClients).thenReturn(true);
  when(scrollController.offset).thenReturn(0);
  when(scrollController.position).thenReturn(scrollPosition);
  when(scrollPosition.viewportDimension).thenReturn(0.0);

  PlutoGridStateManager getStateManager({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
    required FocusNode? gridFocusNode,
    required PlutoGridScrollController scroll,
    List<PlutoColumnGroup>? columnGroups,
  }) {
    return PlutoGridStateManager(
      columns: columns,
      rows: rows,
      columnGroups: columnGroups,
      gridFocusNode: gridFocusNode,
      scroll: scroll,
    )..setEventManager(eventManager);
  }

  testWidgets('columnIndexes - columns 에 맞는 index list 가 리턴 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final List<int> result = stateManager.columnIndexes;

    // then
    expect(result.length, 3);
    expect(result, [0, 1, 2]);
  });

  testWidgets('columnIndexesForShowFrozen - 고정 컬럼 순서에 맞게 리턴 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(
          title: '',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.right,
        ),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(
          title: '',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.left,
        ),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final List<int> result = stateManager.columnIndexesForShowFrozen;

    // then
    expect(result.length, 3);
    expect(result, [2, 1, 0]);
  });

  testWidgets('columnsWidth - 컬럼 넓이 합계를 리턴 해야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
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
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final double result = stateManager.columnsWidth;

    // then
    expect(result, 600);
  });

  testWidgets('leftFrozenColumns - 왼쪽 고정 컬럼 리스트만 리턴 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(
          title: 'left1',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.left,
        ),
        PlutoColumn(title: 'body', field: '', type: PlutoColumnType.text()),
        PlutoColumn(
          title: 'left2',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.left,
        ),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final List<PlutoColumn> result = stateManager.leftFrozenColumns;

    // then
    expect(result.length, 2);
    expect(result[0].title, 'left1');
    expect(result[1].title, 'left2');
  });

  testWidgets('leftFrozenColumnIndexes - 왼쪽 고정 컬럼 인덱스 리스트만 리턴 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(
          title: 'right1',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.right,
        ),
        PlutoColumn(title: 'body', field: '', type: PlutoColumnType.text()),
        PlutoColumn(
          title: 'left2',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.left,
        ),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final List<int> result = stateManager.leftFrozenColumnIndexes;

    // then
    expect(result.length, 1);
    expect(result[0], 2);
  });

  testWidgets('leftFrozenColumnsWidth - 왼쪽 고정 컬럼 넓이 합계를 리턴해야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(
          title: 'right1',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.left,
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
          frozen: PlutoColumnFrozen.left,
          width: 150,
        ),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final double result = stateManager.leftFrozenColumnsWidth;

    // then
    expect(result, 300);
  });

  testWidgets('rightFrozenColumns - 오른쪽 고정 컬럼 리스트만 리턴 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(
          title: 'left1',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.left,
        ),
        PlutoColumn(title: 'body', field: '', type: PlutoColumnType.text()),
        PlutoColumn(
          title: 'right1',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.right,
        ),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final List<PlutoColumn> result = stateManager.rightFrozenColumns;

    // then
    expect(result.length, 1);
    expect(result[0].title, 'right1');
  });

  testWidgets('rightFrozenColumnIndexes - 오른쪽 고정 컬럼 인덱스 리스트만 리턴 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(
          title: 'right1',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.right,
        ),
        PlutoColumn(title: 'body', field: '', type: PlutoColumnType.text()),
        PlutoColumn(
          title: 'right2',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.right,
        ),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final List<int> result = stateManager.rightFrozenColumnIndexes;

    // then
    expect(result.length, 2);
    expect(result[0], 0);
    expect(result[1], 2);
  });

  testWidgets('rightFrozenColumnsWidth - 오른쪽 고정 컬럼 넓이 합계를 리턴해야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        PlutoColumn(
          title: 'right1',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.right,
          width: 120,
        ),
        PlutoColumn(
          title: 'right2',
          field: '',
          type: PlutoColumnType.text(),
          frozen: PlutoColumnFrozen.right,
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
          frozen: PlutoColumnFrozen.left,
          width: 120,
        ),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final double result = stateManager.rightFrozenColumnsWidth;

    // then
    expect(result, 240);
  });

  testWidgets('bodyColumns - body 컬럼 리스트만 리턴 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: PlutoColumnFrozen.left),
        ...ColumnHelper.textColumn('body', count: 3),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: PlutoColumnFrozen.right),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final List<PlutoColumn> result = stateManager.bodyColumns;

    // then
    expect(result.length, 3);
    expect(result[0].title, 'body0');
    expect(result[1].title, 'body1');
    expect(result[2].title, 'body2');
  });

  testWidgets('bodyColumnIndexes - body 컬럼 인덱스 리스트만 리턴 되어야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: PlutoColumnFrozen.left),
        ...ColumnHelper.textColumn('body', count: 3),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: PlutoColumnFrozen.right),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final List<int> result = stateManager.bodyColumnIndexes;

    // then
    expect(result.length, 3);
    expect(result[0], 3);
    expect(result[1], 4);
    expect(result[2], 5);
  });

  testWidgets('bodyColumnsWidth - body 컬럼 넓이 합계를 리턴해야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: PlutoColumnFrozen.left),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: PlutoColumnFrozen.right),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    final double result = stateManager.bodyColumnsWidth;

    // then
    expect(result, 450);
  });

  testWidgets('currentColumn - currentColumnField 값이 없는 경우 null 을 리턴해야 한다.',
      (WidgetTester tester) async {
    // given
    PlutoGridStateManager stateManager = getStateManager(
      columns: [
        ...ColumnHelper.textColumn('left',
            count: 3, frozen: PlutoColumnFrozen.left),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn('right',
            count: 3, frozen: PlutoColumnFrozen.right),
      ],
      rows: [],
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    PlutoColumn? currentColumn = stateManager.currentColumn;

    // when
    expect(currentColumn, null);
  });

  testWidgets('currentColumn - currentCell 이 선택 된 경우 currentColumn 을 리턴해야 한다.',
      (WidgetTester tester) async {
    // given
    List<PlutoColumn> columns = [
      ...ColumnHelper.textColumn('left',
          count: 3, frozen: PlutoColumnFrozen.left),
      ...ColumnHelper.textColumn('body', count: 3, width: 150),
      ...ColumnHelper.textColumn('right',
          count: 3, frozen: PlutoColumnFrozen.right),
    ];

    List<PlutoRow> rows = RowHelper.count(10, columns);

    PlutoGridStateManager stateManager = getStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: null,
      scroll: scroll,
    );

    stateManager.setLayout(
      const BoxConstraints(maxWidth: 1000, maxHeight: 600),
    );

    // when
    String selectColumnField = 'body2';
    stateManager.setCurrentCell(rows[2].cells[selectColumnField], 2);

    PlutoColumn currentColumn = stateManager.currentColumn!;

    // when
    expect(currentColumn, isNot(null));
    expect(currentColumn.field, selectColumnField);
    expect(currentColumn.width, 150);
  });

  testWidgets('currentColumnField - currentCell 이 선택되지 않는 경우 null 을 리턴해야 한다.',
      (WidgetTester tester) async {
    // given
    List<PlutoColumn> columns = [
      ...ColumnHelper.textColumn('left',
          count: 3, frozen: PlutoColumnFrozen.left),
      ...ColumnHelper.textColumn('body', count: 3, width: 150),
      ...ColumnHelper.textColumn('right',
          count: 3, frozen: PlutoColumnFrozen.right),
    ];

    List<PlutoRow> rows = RowHelper.count(10, columns);

    PlutoGridStateManager stateManager = getStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: null,
      scroll: scroll,
    );

    // when
    String? currentColumnField = stateManager.currentColumnField;

    // when
    expect(currentColumnField, null);
  });

  testWidgets(
      'currentColumnField - currentCell 이 선택 된 경우 선택 된 컬럼의 field 를 리턴해야 한다.',
      (WidgetTester tester) async {
    // given
    List<PlutoColumn> columns = [
      ...ColumnHelper.textColumn('left',
          count: 3, frozen: PlutoColumnFrozen.left),
      ...ColumnHelper.textColumn('body', count: 3, width: 150),
      ...ColumnHelper.textColumn('right',
          count: 3, frozen: PlutoColumnFrozen.right),
    ];

    List<PlutoRow> rows = RowHelper.count(10, columns);

    PlutoGridStateManager stateManager = getStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: null,
      scroll: scroll,
    );

    stateManager.setLayout(const BoxConstraints());

    // when
    String selectColumnField = 'body1';
    stateManager.setCurrentCell(rows[2].cells[selectColumnField], 2);

    String? currentColumnField = stateManager.currentColumnField;

    // when
    expect(currentColumnField, isNot(null));
    expect(currentColumnField, selectColumnField);
  });

  group('columnIndexesByShowFrozen', () {
    testWidgets(
        '고정 컬럼이 없는 상태에서 '
        'columnIndexes 가 리턴 되어야 한다.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(const BoxConstraints());

      // when
      // then
      expect(stateManager.columnIndexesByShowFrozen, [0, 1, 2]);
    });

    testWidgets(
        '고정 컬럼이 없는 상태에서 '
        '3번 째 컬럼을 왼쪽 고정 토글 하고 '
        '넓이가 충분한 경우 '
        'columnIndexesForShowFrozen 가 리턴 되어야 한다.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 5, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 1000, maxHeight: 600),
      );

      // when
      stateManager.toggleFrozenColumn(columns[2], PlutoColumnFrozen.left);

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 1000, maxHeight: 600),
      );

      // then
      expect(stateManager.showFrozenColumn, true);
      expect(stateManager.columnIndexesByShowFrozen, [2, 0, 1, 3, 4]);
    });

    testWidgets(
        '고정 컬럼이 없는 상태에서 '
        '3번 째 컬럼을 왼쪽 고정 토글 하고 '
        '넓이가 충분하지 않은 경우 '
        'columnIndexes 가 리턴 되어야 한다.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn('body', count: 5, width: 150),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 300, maxHeight: 600),
      );

      // when
      stateManager.toggleFrozenColumn(columns[2], PlutoColumnFrozen.left);

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 300, maxHeight: 600),
      );

      // then
      expect(stateManager.columnIndexesByShowFrozen, [0, 1, 2, 3, 4]);
    });

    testWidgets(
        '고정 컬럼이 있는 상태에서 '
        '넓이가 충분한 경우 '
        'columnIndexes 가 리턴 되어야 한다.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 1,
          frozen: PlutoColumnFrozen.left,
          width: 150,
        ),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 1,
          frozen: PlutoColumnFrozen.right,
          width: 150,
        ),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager
          .setLayout(const BoxConstraints(maxWidth: 500, maxHeight: 600));

      // when
      // then
      expect(stateManager.columnIndexesByShowFrozen, [0, 1, 2, 3, 4]);
    });

    testWidgets(
        '고정 컬럼이 있는 상태에서 '
        '고정 컬럼 하나를 토글하여 왼쪽 추가하고  '
        '넓이가 충분한 경우 '
        'columnIndexesForShowFrozen 가 리턴 되어야 한다.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 1,
          frozen: PlutoColumnFrozen.left,
          width: 150,
        ),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 1,
          frozen: PlutoColumnFrozen.right,
          width: 150,
        ),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 700, maxHeight: 600),
      );

      stateManager.toggleFrozenColumn(columns[2], PlutoColumnFrozen.left);

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 700, maxHeight: 600),
      );

      // when
      // then
      expect(stateManager.columnIndexesByShowFrozen, [0, 2, 1, 3, 4]);
    });

    testWidgets(
        '고정 컬럼이 있는 상태에서 '
        '고정 컬럼 하나를 토글하여 오른쪽 추가하고  '
        '넓이가 충분한 경우 '
        'columnIndexesForShowFrozen 가 리턴 되어야 한다.', (WidgetTester tester) async {
      // given
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 1,
          frozen: PlutoColumnFrozen.left,
          width: 150,
        ),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 1,
          frozen: PlutoColumnFrozen.right,
          width: 150,
        ),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 700, maxHeight: 600),
      );

      stateManager.toggleFrozenColumn(columns[2], PlutoColumnFrozen.right);

      stateManager.setLayout(
        const BoxConstraints(maxWidth: 700, maxHeight: 600),
      );

      // when
      // then
      expect(stateManager.columnIndexesByShowFrozen, [0, 1, 3, 2, 4]);
    });
  });

  testWidgets(
    '고정 컬럼이 있고 넓이가 넓이가 충분한 경우 고정 컬럼이 보여지는 상태에서, '
    '고정 컬럼 넓이를 제약범위보다 크게 변경하면 넓이가 변경 되지 않아야 한다.',
    (WidgetTester tester) async {
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 1,
          frozen: PlutoColumnFrozen.left,
          width: 150,
        ),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 1,
          frozen: PlutoColumnFrozen.right,
          width: 150,
        ),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      // 150 + 200 + 150 = 최소 500 필요
      stateManager
          .setLayout(const BoxConstraints(maxWidth: 550, maxHeight: 600));

      expect(stateManager.showFrozenColumn, true);
      expect(columns.first.width, 150);

      // 최소 넓이에서 남는 50 이상 크기를 키움
      stateManager.resizeColumn(columns.first, 60);

      expect(stateManager.showFrozenColumn, true);
      expect(columns.first.width, 150);
    },
  );

  testWidgets(
    '고정 컬럼이 있지만 넓이가 좁아 고정 컬럼이 풀리면, '
    '고정 시킨 컬럼 설정이 풀려야 된다.',
    (WidgetTester tester) async {
      List<PlutoColumn> columns = [
        ...ColumnHelper.textColumn(
          'left',
          count: 1,
          frozen: PlutoColumnFrozen.left,
          width: 150,
        ),
        ...ColumnHelper.textColumn('body', count: 3, width: 150),
        ...ColumnHelper.textColumn(
          'right',
          count: 1,
          frozen: PlutoColumnFrozen.right,
          width: 150,
        ),
      ];

      List<PlutoRow> rows = RowHelper.count(10, columns);

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: rows,
        gridFocusNode: null,
        scroll: scroll,
      );

      // 150 + 200 + 150 = 최소 500 필요
      stateManager.setLayout(
        const BoxConstraints(maxWidth: 450, maxHeight: 600),
      );

      expect(stateManager.showFrozenColumn, false);
      expect(stateManager.columns[0].frozen, PlutoColumnFrozen.none);
      expect(stateManager.columns[1].frozen, PlutoColumnFrozen.none);
      expect(stateManager.columns[2].frozen, PlutoColumnFrozen.none);
      expect(stateManager.columns[3].frozen, PlutoColumnFrozen.none);
      expect(stateManager.columns[4].frozen, PlutoColumnFrozen.none);
    },
  );

  group('insertColumns', () {
    testWidgets(
      '기존 컬럼이 없는 상태에서 0번 인덱스에 컬럼 1개가 추가 되어야 한다.',
      (WidgetTester tester) async {
        const columnIdxToInsert = 0;

        final List<PlutoColumn> columnsToInsert = ColumnHelper.textColumn(
          'column',
          count: 1,
        );

        final List<PlutoColumn> columns = [];

        final List<PlutoRow> rows = [];

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.insertColumns(columnIdxToInsert, columnsToInsert);

        expect(stateManager.refColumns.length, 1);
      },
    );

    testWidgets(
      '기존 컬럼 1개 있는 상태에서 0번 인덱스에 컬럼 1개가 추가 되어야 한다.',
      (WidgetTester tester) async {
        const columnIdxToInsert = 0;

        final List<PlutoColumn> columnsToInsert = ColumnHelper.textColumn(
          'column',
          count: 1,
          start: 1,
        );

        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 1,
          start: 0,
        );

        final List<PlutoRow> rows = [];

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.insertColumns(columnIdxToInsert, columnsToInsert);

        expect(stateManager.refColumns.length, 2);

        expect(stateManager.refColumns[0].key, columnsToInsert[0].key);
      },
    );

    testWidgets(
      '기존 컬럼 1개 있는 상태에서 추가된 컬럼의 셀이 행에 추가 되어야 한다.',
      (WidgetTester tester) async {
        const columnIdxToInsert = 0;

        const defaultValue = 'inserted column';

        final List<PlutoColumn> columnsToInsert = ColumnHelper.textColumn(
          'column',
          count: 1,
          start: 1,
          defaultValue: defaultValue,
        );

        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 1,
          start: 0,
        );

        final List<PlutoRow> rows = RowHelper.count(2, columns);

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.insertColumns(columnIdxToInsert, columnsToInsert);

        expect(
          stateManager.refRows[0].cells['column1']!.value,
          defaultValue,
        );

        expect(
          stateManager.refRows[1].cells['column1']!.value,
          defaultValue,
        );
      },
    );
  });

  group('removeColumns', () {
    testWidgets(
      '0번 컬럼을 삭제하면 컬럼이 삭제되어야 한다.',
      (WidgetTester tester) async {
        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 10,
        );

        final List<PlutoRow> rows = RowHelper.count(2, columns);

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.removeColumns([columns[0]]);

        expect(stateManager.refColumns.length, 9);
      },
    );

    testWidgets(
      '0번 컬럼을 삭제하면 해당 컬럼의 셀이 삭제 되어야 한다.',
      (WidgetTester tester) async {
        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 10,
        );

        final List<PlutoRow> rows = RowHelper.count(2, columns);

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        expect(stateManager.refRows[0].cells.entries.length, 10);

        stateManager.removeColumns([columns[0]]);

        expect(stateManager.refRows[0].cells.entries.length, 9);
      },
    );

    testWidgets(
      '8, 8번 컬럼을 삭제하면 해당 컬럼의 셀이 삭제 되어야 한다.',
      (WidgetTester tester) async {
        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 10,
        );

        final List<PlutoRow> rows = RowHelper.count(2, columns);

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        expect(stateManager.refRows[0].cells.entries.length, 10);

        stateManager.removeColumns([columns[8], columns[9]]);

        expect(stateManager.refRows[0].cells.entries.length, 8);
      },
    );

    testWidgets(
      '컬럼 그룹이 있는 상태에서 컬럼을 삭제하면 빈 그룹이 삭제 되어야 한다.',
      (WidgetTester tester) async {
        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 10,
        );

        final List<PlutoColumnGroup> columnGroups = [
          PlutoColumnGroup(title: 'a', fields: ['column0']),
          PlutoColumnGroup(
              title: 'b',
              fields: columns
                  .where((element) => element.field != 'column0')
                  .map((e) => e.field)
                  .toList()),
        ];

        final List<PlutoRow> rows = RowHelper.count(2, columns);

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          columnGroups: columnGroups,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.removeColumns([columns[0]]);

        expect(stateManager.columnGroups.length, 1);

        expect(stateManager.columnGroups[0].title, 'b');
      },
    );

    testWidgets(
      '컬럼 그룹이 있는 상태에서 컬럼을 삭제하면 해당 그룹에서 컬럼이 삭제되어야 한다.',
      (WidgetTester tester) async {
        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 10,
        );

        final List<PlutoColumnGroup> columnGroups = [
          PlutoColumnGroup(title: 'a', fields: ['column0']),
          PlutoColumnGroup(
              title: 'b',
              fields: columns
                  .where((element) => element.field != 'column0')
                  .map((e) => e.field)
                  .toList()),
        ];

        final List<PlutoRow> rows = RowHelper.count(2, columns);

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          columnGroups: columnGroups,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.removeColumns([columns[1]]);

        expect(stateManager.columnGroups.length, 2);

        expect(
          stateManager.columnGroups[1].fields!.contains('column1'),
          false,
        );

        expect(stateManager.columnGroups[1].fields!.length, 8);
      },
    );

    testWidgets(
      '하위 컬럼 그룹이 있는 상태에서 컬럼을 삭제하면 빈 해당 하위 그룹이 삭제 되어야 한다.',
      (WidgetTester tester) async {
        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 10,
        );

        final List<PlutoColumnGroup> columnGroups = [
          PlutoColumnGroup(title: 'a', fields: ['column0']),
          PlutoColumnGroup(
            title: 'b',
            children: [
              PlutoColumnGroup(title: 'c', fields: ['column1']),
              PlutoColumnGroup(
                  title: 'd',
                  fields: columns
                      .where((element) =>
                          !['column0', 'column1'].contains(element.field))
                      .map((e) => e.field)
                      .toList()),
            ],
          ),
        ];

        final List<PlutoRow> rows = RowHelper.count(2, columns);

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          columnGroups: columnGroups,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        expect(stateManager.columnGroups[1].children!.length, 2);

        stateManager.removeColumns([columns[1]]);

        expect(stateManager.columnGroups[1].children!.length, 1);

        expect(stateManager.columnGroups[1].children![0].title, 'd');
      },
    );

    testWidgets(
      '필터가 있는 컬럼을 삭제 한 경우 해당 컬럼의 필터가 삭제 되어야 한다.',
      (WidgetTester tester) async {
        final List<PlutoColumn> columns = ColumnHelper.textColumn(
          'column',
          count: 10,
        );

        final List<PlutoRow> rows = RowHelper.count(2, columns);

        final List<PlutoRow> filterRows = [
          FilterHelper.createFilterRow(
            columnField: columns[0].field,
            filterType: const PlutoFilterTypeContains(),
            filterValue: 'filter',
          ),
          FilterHelper.createFilterRow(
            columnField: columns[0].field,
            filterType: const PlutoFilterTypeContains(),
            filterValue: 'filter',
          ),
        ];

        PlutoGridStateManager stateManager = getStateManager(
          columns: columns,
          rows: rows,
          gridFocusNode: null,
          scroll: scroll,
        );

        stateManager.setFilterWithFilterRows(filterRows);

        expect(stateManager.filterRows.length, 2);

        stateManager.removeColumns([columns[0]]);

        expect(stateManager.filterRows.length, 0);
      },
    );
  });

  group('hideColumn', () {
    testWidgets('flag 를 true 로 호출 한 경우 컬럼의 hide 가 true 로 변경 되어야 한다.',
        (WidgetTester tester) async {
      // given
      var columns = [
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
      ];

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      // when
      expect(stateManager.columns.first.hide, isFalse);

      stateManager.hideColumn(columns.first, true);

      // then
      expect(stateManager.refColumns.originalList.first.hide, isTrue);
    });

    testWidgets(
        'hide 가 true 인 컬럼을 flag 를 false 로 호출하여 hide 가 false 로 변경 되어야 한다.',
        (WidgetTester tester) async {
      // given
      var columns = [
        PlutoColumn(
          title: '',
          field: '',
          type: PlutoColumnType.text(),
          hide: true,
        ),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
      ];

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      // when
      expect(stateManager.refColumns.originalList.first.hide, isTrue);

      stateManager.hideColumn(columns.first, false);

      // then
      expect(stateManager.columns.first.hide, isFalse);
    });

    testWidgets('flag 를 true 로 호출 한 경우 notifyListeners 가 호출 되어야 한다.',
        (WidgetTester tester) async {
      // given
      var columns = [
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
      ];

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      var listeners = MockOnChangeListener();

      stateManager.addListener(listeners.onChangeVoidNoParamListener);

      // when
      expect(stateManager.columns.first.hide, isFalse);

      stateManager.hideColumn(columns.first, true);

      // then
      verify(listeners.onChangeVoidNoParamListener()).called(1);
    });

    testWidgets(
        'hide 가 false 이 경우 flag 를 false 로 호출 하면 notifyListeners 가 호출 되지 않아야 한다.',
        (WidgetTester tester) async {
      // given
      var columns = [
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
        PlutoColumn(title: '', field: '', type: PlutoColumnType.text()),
      ];

      PlutoGridStateManager stateManager = getStateManager(
        columns: columns,
        rows: [],
        gridFocusNode: null,
        scroll: scroll,
      );

      var listeners = MockOnChangeListener();

      stateManager.addListener(listeners.onChangeVoidNoParamListener);

      // when
      expect(stateManager.columns.first.hide, isFalse);

      stateManager.hideColumn(columns.first, false);

      // then
      verifyNever(listeners.onChangeVoidNoParamListener());
    });
  });
}
