import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../matcher/pluto_object_matcher.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late MockPlutoGridStateManager stateManager;
  late MockPlutoGridScrollController scroll;
  late MockLinkedScrollControllerGroup horizontalScroll;
  late MockScrollController horizontalScrollController;
  late MockLinkedScrollControllerGroup verticalScroll;
  late MockScrollController verticalScrollController;
  late MockPlutoGridEventManager eventManager;
  late PlutoGridKeyPressed keyPressed;
  late MockScrollPosition horizontalScrollPosition;
  late MockScrollPosition verticalScrollPosition;

  eventBuilder({
    required PlutoGridGestureType gestureType,
    Offset? offset,
    PlutoCell? cell,
    PlutoColumn? column,
    int? rowIdx,
  }) =>
      PlutoGridCellGestureEvent(
        gestureType: gestureType,
        offset: offset ?? Offset.zero,
        cell: cell ?? PlutoCell(value: 'value'),
        column: column ??
            PlutoColumn(
              title: 'column',
              field: 'column',
              type: PlutoColumnType.text(),
            ),
        rowIdx: rowIdx ?? 0,
      );

  setUp(() {
    stateManager = MockPlutoGridStateManager();
    scroll = MockPlutoGridScrollController();
    horizontalScroll = MockLinkedScrollControllerGroup();
    horizontalScrollController = MockScrollController();
    verticalScroll = MockLinkedScrollControllerGroup();
    verticalScrollController = MockScrollController();
    eventManager = MockPlutoGridEventManager();
    keyPressed = MockPlutoGridKeyPressed();
    horizontalScrollPosition = MockScrollPosition();
    verticalScrollPosition = MockScrollPosition();

    when(stateManager.eventManager).thenReturn(eventManager);
    when(stateManager.scroll).thenReturn(scroll);
    when(stateManager.isLTR).thenReturn(true);
    when(stateManager.keyPressed).thenReturn(keyPressed);
    when(scroll.horizontal).thenReturn(horizontalScroll);
    when(scroll.bodyRowsHorizontal).thenReturn(horizontalScrollController);
    when(scroll.vertical).thenReturn(verticalScroll);
    when(scroll.bodyRowsVertical).thenReturn(verticalScrollController);
    when(horizontalScroll.offset).thenReturn(0.0);
    when(verticalScroll.offset).thenReturn(0.0);
    when(horizontalScrollController.hasClients).thenReturn(true);
    when(verticalScrollController.hasClients).thenReturn(true);
    when(horizontalScrollController.position).thenReturn(horizontalScrollPosition);
    when(verticalScrollController.position).thenReturn(verticalScrollPosition);
    when(horizontalScrollPosition.maxScrollExtent).thenReturn(1000);
    when(verticalScrollPosition.maxScrollExtent).thenReturn(1000);
    when(stateManager.columnRowContainerHeight).thenReturn(300);
    when(stateManager.columnGroupHeight).thenReturn(0);
    when(stateManager.columnHeight).thenReturn(0);
    when(stateManager.columnFilterHeight).thenReturn(0);
    when(stateManager.columnFooterHeight).thenReturn(0);
    when(stateManager.rowTotalHeight).thenReturn(50);
    when(stateManager.maxWidth).thenReturn(400);
    when(stateManager.leftFrozenColumnsWidth).thenReturn(0);
    when(stateManager.rightFrozenColumnsWidth).thenReturn(0);
    when(stateManager.scrollOffsetByFrozenColumn).thenReturn(0);
    when(stateManager.showFrozenColumn).thenReturn(false);
  });

  group('onTapUp', () {
    test(
      'When, '
      'hasFocus = false, '
      'isCurrentCell = true, '
      'Then, '
      'setKeepFocus(true) 가 호출 되고, '
      'isCurrentCell 가 true 인 경우 return 되어야 한다.',
      () {
        // given
        when(stateManager.hasFocus).thenReturn(false);
        when(stateManager.isCurrentCell(any)).thenReturn(true);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(gestureType: PlutoGridGestureType.onTapUp);
        event.handler(stateManager);

        // then
        verify(stateManager.setKeepFocus(true)).called(1);
        // return 이후 호출 되지 않아야 할 메소드
        verifyNever(stateManager.setEditing(any));
        verifyNever(stateManager.setCurrentCell(any, any));
      },
    );

    test(
      'When, '
      'hasFocus = false, '
      'isCurrentCell = false, '
      'isSelectingInteraction = false, '
      'PlutoMode = normal, '
      'isEditing = true, '
      'Then, '
      'setKeepFocus(true) 가 호출 되고, '
      'setCurrentCell 이 호출 되어야 한다.',
      () {
        // given
        when(stateManager.hasFocus).thenReturn(false);
        when(stateManager.isCurrentCell(any)).thenReturn(false);
        when(stateManager.isSelectingInteraction()).thenReturn(false);
        when(stateManager.mode).thenReturn(PlutoGridMode.normal);
        when(stateManager.isEditing).thenReturn(true);
        clearInteractions(stateManager);

        final cell = PlutoCell(value: 'value');
        const rowIdx = 1;

        // when
        var event = eventBuilder(
          gestureType: PlutoGridGestureType.onTapUp,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.setKeepFocus(true)).called(1);
        verify(stateManager.setCurrentCell(cell, rowIdx)).called(1);
        // 호출 되지 않아야 할 메소드
        verifyNever(stateManager.setEditing(any));
      },
    );

    test('should reposition vertical scroll when tapped row is above viewport.',
        () {
      // given
      when(stateManager.hasFocus).thenReturn(true);
      when(stateManager.isCurrentCell(any)).thenReturn(false);
      when(stateManager.isSelectingInteraction()).thenReturn(false);
      when(stateManager.mode).thenReturn(PlutoGridMode.normal);
      when(stateManager.isEditing).thenReturn(true);
      when(verticalScroll.offset).thenReturn(40);
      when(scroll.verticalOffset).thenReturn(40);
      when(scroll.maxScrollVertical).thenReturn(1000);
      clearInteractions(stateManager);
      clearInteractions(verticalScroll);

      final cell = PlutoCell(value: 'value');
      const rowIdx = 0;

      // when
      final event = eventBuilder(
        gestureType: PlutoGridGestureType.onTapUp,
        cell: cell,
        rowIdx: rowIdx,
      );
      event.handler(stateManager);

      // then
      verify(stateManager.setCurrentCell(cell, rowIdx)).called(1);
      verify(verticalScroll.jumpTo(0)).called(1);
    });

    test('should reposition horizontal scroll when tapped column is clipped.',
        () {
      // given
      when(stateManager.hasFocus).thenReturn(true);
      when(stateManager.isCurrentCell(any)).thenReturn(false);
      when(stateManager.isSelectingInteraction()).thenReturn(false);
      when(stateManager.mode).thenReturn(PlutoGridMode.normal);
      when(stateManager.isEditing).thenReturn(true);
      when(horizontalScroll.offset).thenReturn(0);
      when(scroll.horizontalOffset).thenReturn(0);
      when(scroll.maxScrollHorizontal).thenReturn(1000);
      clearInteractions(stateManager);
      clearInteractions(horizontalScroll);

      final column = PlutoColumn(
        title: 'column',
        field: 'column',
        type: PlutoColumnType.text(),
        width: 120,
      )
        ..startPosition = 350;
      final cell = PlutoCell(value: 'value');
      const rowIdx = 1;

      // when
      final event = eventBuilder(
        gestureType: PlutoGridGestureType.onTapUp,
        cell: cell,
        column: column,
        rowIdx: rowIdx,
      );
      event.handler(stateManager);

      // then
      verify(stateManager.setCurrentCell(cell, rowIdx)).called(1);
      verify(horizontalScroll.jumpTo(70)).called(1);
    });

    test(
      'When, '
      'hasFocus = true, '
      'isCurrentCell = true, '
      'isSelectingInteraction = false, '
      'PlutoMode = normal, '
      'isEditing = false, '
      'Then, '
      'setEditing(true) 가 호출 되어야 한다.',
      () {
        // given
        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.isCurrentCell(any)).thenReturn(true);
        when(stateManager.isSelectingInteraction()).thenReturn(false);
        when(stateManager.mode).thenReturn(PlutoGridMode.normal);
        when(stateManager.isEditing).thenReturn(false);
        clearInteractions(stateManager);

        final cell = PlutoCell(value: 'value');
        const rowIdx = 1;

        // when
        var event = eventBuilder(
          gestureType: PlutoGridGestureType.onTapUp,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.setEditing(true)).called(1);
        // 호출 되지 않아야 할 메소드
        verifyNever(stateManager.setKeepFocus(true));
        verifyNever(stateManager.setCurrentCell(any, any));
      },
    );

    test(
      'When, '
      'hasFocus = true, '
      'isSelectingInteraction = true, '
      'keyPressed.shift = true, '
      'Then, '
      'setCurrentSelectingPosition 가 호출 되어야 한다.',
      () {
        // given
        final column = ColumnHelper.textColumn('column').first;
        final cell = PlutoCell(value: 'value');
        const columnIdx = 1;
        const rowIdx = 1;

        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.isSelectingInteraction()).thenReturn(true);
        when(keyPressed.shift).thenReturn(true);
        when(stateManager.columnIndex(column)).thenReturn(columnIdx);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: PlutoGridGestureType.onTapUp,
          cell: cell,
          rowIdx: rowIdx,
          column: column,
        );
        event.handler(stateManager);

        // then
        verify(
          stateManager.setCurrentSelectingPosition(
              cellPosition: const PlutoGridCellPosition(
            columnIdx: columnIdx,
            rowIdx: rowIdx,
          )),
        ).called(1);
        // 호출 되지 않아야 할 메소드
        verifyNever(stateManager.setKeepFocus(true));
        verifyNever(stateManager.toggleSelectingRow(any));
      },
    );

    test(
      'When, '
      'hasFocus = true, '
      'isSelectingInteraction = true, '
      'keyPressed.ctrl = true, '
      'Then, '
      'toggleSelectingRow 가 호출 되어야 한다.',
      () {
        // given
        final cell = PlutoCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.isSelectingInteraction()).thenReturn(true);
        when(keyPressed.ctrl).thenReturn(true);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: PlutoGridGestureType.onTapUp,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(
          stateManager.toggleSelectingRow(rowIdx),
        ).called(1);
        // 호출 되지 않아야 할 메소드
        verifyNever(stateManager.setKeepFocus(true));
        verifyNever(stateManager.setCurrentSelectingPosition(
          cellPosition: anyNamed('cellPosition'),
        ));
      },
    );

    test(
      'When, '
      'hasFocus = true, '
      'isSelectingInteraction = false, '
      'PlutoMode = select, '
      'isCurrentCell = true, '
      'Then, '
      'handleOnSelected 가 호출 되어야 한다.',
      () {
        // given
        final cell = PlutoCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.isSelectingInteraction()).thenReturn(false);
        when(stateManager.mode).thenReturn(PlutoGridMode.select);
        when(stateManager.isCurrentCell(any)).thenReturn(true);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: PlutoGridGestureType.onTapUp,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.handleOnSelected()).called(1);
        // 호출 되지 않아야 할 메소드
        verifyNever(stateManager.setCurrentCell(any, any));
      },
    );

    test(
      'When, '
      'hasFocus = true, '
      'isSelectingInteraction = false, '
      'PlutoMode = select, '
      'isCurrentCell = false, '
      'Then, '
      'setCurrentCell 가 호출 되어야 한다.',
      () {
        // given
        final cell = PlutoCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.isSelectingInteraction()).thenReturn(false);
        when(stateManager.mode).thenReturn(PlutoGridMode.select);
        when(stateManager.isCurrentCell(any)).thenReturn(false);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: PlutoGridGestureType.onTapUp,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.setCurrentCell(cell, rowIdx));
        // 호출 되지 않아야 할 메소드
        verifyNever(stateManager.handleOnSelected());
      },
    );
  });

  group('onLongPressStart', () {
    test(
      'When, '
      'isCurrentCell = false, '
      'Then, '
      'setCurrentCell, setSelecting 이 호출 되어야 한다.',
      () {
        // given
        final cell = PlutoCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.isCurrentCell(any)).thenReturn(false);
        when(stateManager.selectingMode).thenReturn(
          PlutoGridSelectingMode.cell,
        );
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: PlutoGridGestureType.onLongPressStart,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.isCurrentCell(cell));
        verify(stateManager.setCurrentCell(cell, rowIdx, notify: false));
        verify(stateManager.setSelecting(true));
      },
    );

    test(
      'When, '
      'isCurrentCell = true, '
      'Then, '
      'setCurrentCell 이 호출 되지 않아야 한다.',
      () {
        // given
        final cell = PlutoCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.isCurrentCell(any)).thenReturn(true);
        when(stateManager.selectingMode).thenReturn(
          PlutoGridSelectingMode.cell,
        );
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: PlutoGridGestureType.onLongPressStart,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verifyNever(stateManager.setCurrentCell(cell, rowIdx, notify: false));
      },
    );

    test(
      'When, '
      'isCurrentCell = false, '
      'selectingMode = Row, '
      'Then, '
      'toggleSelectingRow 가 호출 되어야 한다.',
      () {
        // given
        final cell = PlutoCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.isCurrentCell(any)).thenReturn(false);
        when(stateManager.selectingMode).thenReturn(PlutoGridSelectingMode.row);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: PlutoGridGestureType.onLongPressStart,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.toggleSelectingRow(rowIdx));
      },
    );
  });

  group('onLongPressMoveUpdate', () {
    test(
      'setCurrentSelectingPositionWithOffset, addEvent 가 호출 되어야 한다.',
      () {
        // given
        const offset = Offset(2.0, 3.0);
        final cell = PlutoCell(value: 'value');
        const rowIdx = 1;

        when(stateManager.isCurrentCell(any)).thenReturn(false);
        when(stateManager.selectingMode).thenReturn(PlutoGridSelectingMode.row);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: PlutoGridGestureType.onLongPressMoveUpdate,
          offset: offset,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.setCurrentSelectingPositionWithOffset(offset));
        verify(eventManager.addEvent(argThat(
            PlutoObjectMatcher<PlutoGridScrollUpdateEvent>(rule: (event) {
          return event.offset == offset;
        }))));
      },
    );
  });

  group('onLongPressEnd', () {
    test(
      'setSelecting 이 false 로 호출 되어야 한다.',
      () {
        // given
        final cell = PlutoCell(value: 'value');
        const rowIdx = 1;

        // when
        when(stateManager.isCurrentCell(any)).thenReturn(true);

        var event = eventBuilder(
          gestureType: PlutoGridGestureType.onLongPressEnd,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.setSelecting(false));
      },
    );
  });
}
