import 'package:flutter_test/flutter_test.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'pluto_grid_scroll_update_event_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<PlutoGridStateManager>(returnNullOnMissingStub: true),
  MockSpec<LinkedScrollControllerGroup>(returnNullOnMissingStub: true),
])
void main() {
  MockPlutoGridStateManager? stateManager;
  PlutoGridScrollController scrollController;
  MockLinkedScrollControllerGroup? vertical;
  MockLinkedScrollControllerGroup? horizontal;

  eventBuilder({
    Offset? offset,
  }) =>
      PlutoGridScrollUpdateEvent(
        offset: offset,
      );

  setUp(() {
    stateManager = MockPlutoGridStateManager();
    vertical = MockLinkedScrollControllerGroup();
    horizontal = MockLinkedScrollControllerGroup();
    scrollController = PlutoGridScrollController(
      vertical: vertical,
      horizontal: horizontal,
    );
    when(stateManager!.scroll).thenReturn(scrollController);
  });

  group('인수 값 테스트', () {
    test(
      'offset 이 null 이면 return 되어야 한다.',
      () {
        var event = eventBuilder(offset: null);
        event.handler(stateManager);

        verifyNever(stateManager!.needMovingScroll(any, any));
        verifyNever(horizontal!.animateTo(
          any,
          curve: anyNamed('curve'),
          duration: anyNamed('duration'),
        ));
      },
    );

    test(
      'offset 이 null 가 아니면 needMovingScroll 이 호출 되어야 한다.',
      () {
        when(stateManager!.needMovingScroll(any, any)).thenReturn(false);

        var event = eventBuilder(offset: const Offset(0, 0));
        event.handler(stateManager);

        verify(stateManager!.needMovingScroll(any, any)).called(4);
      },
    );

    test(
      'needMovingScroll(offset, PlutoMoveDirection.left) 가 true 면, '
      'horizontal scroll 의 animateTo 가 offset 보다 작게 호출 되어야 한다.',
      () {
        const offset = Offset(10, 10);
        const scrollOffset = 0.0;

        when(horizontal!.offset).thenReturn(scrollOffset);

        when(stateManager!.needMovingScroll(offset, PlutoMoveDirection.left))
            .thenReturn(true);
        when(stateManager!.needMovingScroll(offset, PlutoMoveDirection.right))
            .thenReturn(false);
        when(stateManager!.needMovingScroll(offset, PlutoMoveDirection.up))
            .thenReturn(false);
        when(stateManager!.needMovingScroll(offset, PlutoMoveDirection.down))
            .thenReturn(false);

        var event = eventBuilder(offset: offset);
        event.handler(stateManager);

        verify(horizontal!.animateTo(
          scrollOffset - PlutoGridSettings.offsetScrollingFromEdgeAtOnce,
          curve: anyNamed('curve'),
          duration: anyNamed('duration'),
        ));
      },
    );

    test(
      'needMovingScroll(offset, PlutoMoveDirection.right) 가 true 면, '
      'horizontal scroll 의 animateTo 가 offset 보다 크게 호출 되어야 한다.',
      () {
        const offset = Offset(10, 10);
        const scrollOffset = 0.0;

        when(horizontal!.offset).thenReturn(scrollOffset);

        when(stateManager!.needMovingScroll(offset, PlutoMoveDirection.left))
            .thenReturn(false);
        when(stateManager!.needMovingScroll(offset, PlutoMoveDirection.right))
            .thenReturn(true);
        when(stateManager!.needMovingScroll(offset, PlutoMoveDirection.up))
            .thenReturn(false);
        when(stateManager!.needMovingScroll(offset, PlutoMoveDirection.down))
            .thenReturn(false);

        var event = eventBuilder(offset: offset);
        event.handler(stateManager);

        verify(horizontal!.animateTo(
          scrollOffset + PlutoGridSettings.offsetScrollingFromEdgeAtOnce,
          curve: anyNamed('curve'),
          duration: anyNamed('duration'),
        ));
      },
    );

    test(
      'needMovingScroll(offset, PlutoMoveDirection.up) 가 true 면, '
      'vertical scroll 의 animateTo 가 offset 보다 작게 호출 되어야 한다.',
      () {
        const offset = Offset(10, 10);
        const scrollOffset = 0.0;

        when(vertical!.offset).thenReturn(scrollOffset);

        when(stateManager!.needMovingScroll(offset, PlutoMoveDirection.left))
            .thenReturn(false);
        when(stateManager!.needMovingScroll(offset, PlutoMoveDirection.right))
            .thenReturn(false);
        when(stateManager!.needMovingScroll(offset, PlutoMoveDirection.up))
            .thenReturn(true);
        when(stateManager!.needMovingScroll(offset, PlutoMoveDirection.down))
            .thenReturn(false);

        var event = eventBuilder(offset: offset);
        event.handler(stateManager);

        verify(vertical!.animateTo(
          scrollOffset - PlutoGridSettings.offsetScrollingFromEdgeAtOnce,
          curve: anyNamed('curve'),
          duration: anyNamed('duration'),
        ));
      },
    );

    test(
      'needMovingScroll(offset, PlutoMoveDirection.down) 가 true 면, '
      'vertical scroll 의 animateTo 가 offset 보다 크게 호출 되어야 한다.',
      () {
        const offset = Offset(10, 10);
        const scrollOffset = 0.0;

        when(vertical!.offset).thenReturn(scrollOffset);

        when(stateManager!.needMovingScroll(offset, PlutoMoveDirection.left))
            .thenReturn(false);
        when(stateManager!.needMovingScroll(offset, PlutoMoveDirection.right))
            .thenReturn(false);
        when(stateManager!.needMovingScroll(offset, PlutoMoveDirection.up))
            .thenReturn(false);
        when(stateManager!.needMovingScroll(offset, PlutoMoveDirection.down))
            .thenReturn(true);

        var event = eventBuilder(offset: offset);
        event.handler(stateManager);

        verify(vertical!.animateTo(
          scrollOffset + PlutoGridSettings.offsetScrollingFromEdgeAtOnce,
          curve: anyNamed('curve'),
          duration: anyNamed('duration'),
        ));
      },
    );
  });
}
