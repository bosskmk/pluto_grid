import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'pluto_grid_cell_gesture_event_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<PlutoGridStateManager>(returnNullOnMissingStub: true),
])
void main() {
  MockPlutoGridStateManager? stateManager;

  setUp(() {
    stateManager = MockPlutoGridStateManager();
  });

  group('인수 값 테스트', () {
    test(
      'dragType 이 null 이면 return 되어야 한다.',
      () {
        var event = PlutoGridDragRowsEvent(dragType: null);
        event.handler(stateManager);

        verifyNever(stateManager!.setIsDraggingRow(any, notify: false));
        verifyNever(stateManager!.setDragRows(any));
        verifyNever(stateManager!.setDragTargetRowIdx(any));
        verifyNever(stateManager!.moveRowsByOffset(any, any, notify: false));
      },
    );

    test(
      'dragType 이 start 가 아니고 offset 이 null 이면 return 되어야 한다.',
      () {
        var event = PlutoGridDragRowsEvent(
          dragType: PlutoGridDragType.update,
          offset: null,
        );
        event.handler(stateManager);

        verifyNever(stateManager!.setIsDraggingRow(any, notify: false));
        verifyNever(stateManager!.setDragRows(any));
        verifyNever(stateManager!.setDragTargetRowIdx(any));
        verifyNever(stateManager!.moveRowsByOffset(any, any, notify: false));
      },
    );

    test(
      'rows 가 null 이면 return 되어야 한다.',
      () {
        var event = PlutoGridDragRowsEvent(
          dragType: PlutoGridDragType.update,
          offset: const Offset(0, 0),
          rows: null,
        );
        event.handler(stateManager);

        verifyNever(stateManager!.setIsDraggingRow(any, notify: false));
        verifyNever(stateManager!.setDragRows(any));
        verifyNever(stateManager!.setDragTargetRowIdx(any));
        verifyNever(stateManager!.moveRowsByOffset(any, any, notify: false));
      },
    );

    test(
      'dragType 이 start 면, '
      'setIsDraggingRow, setDragRows 이 호출 되어야 한다.',
      () {
        var event = PlutoGridDragRowsEvent(
          dragType: PlutoGridDragType.start,
          offset: const Offset(0, 0),
          rows: [],
        );
        event.handler(stateManager);

        verify(stateManager!.setIsDraggingRow(true, notify: false));
        verify(stateManager!.setDragRows(any));
        // 호출 되지 않아야 되는 메소드
        verifyNever(stateManager!.setDragTargetRowIdx(any));
        verifyNever(stateManager!.moveRowsByOffset(any, any, notify: false));
      },
    );

    test(
      'dragType 이 update 면, '
      'setDragTargetRowIdx 이 호출 되어야 한다.',
      () {
        var event = PlutoGridDragRowsEvent(
          dragType: PlutoGridDragType.update,
          offset: const Offset(0, 0),
          rows: [],
        );
        event.handler(stateManager);

        verify(stateManager!.setDragTargetRowIdx(any));
        // 호출 되지 않아야 되는 메소드
        verifyNever(stateManager!.setIsDraggingRow(true, notify: false));
        verifyNever(stateManager!.setDragRows(any));
        verifyNever(stateManager!.moveRowsByOffset(any, any, notify: false));
      },
    );

    test(
      'dragType 이 end 면, '
      'moveRows, setIsDraggingRow 이 호출 되어야 한다.',
      () {
        var event = PlutoGridDragRowsEvent(
          dragType: PlutoGridDragType.end,
          offset: const Offset(0, 0),
          rows: [],
        );
        event.handler(stateManager);

        verify(stateManager!.moveRowsByOffset(any, any, notify: false));
        verify(stateManager!.setIsDraggingRow(false));
        // 호출 되지 않아야 되는 메소드
        verifyNever(stateManager!.setDragTargetRowIdx(any));
        verifyNever(stateManager!.setDragRows(any));
      },
    );
  });
}
