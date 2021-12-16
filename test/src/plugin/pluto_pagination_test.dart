import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../helper/pluto_widget_test_helper.dart';
import '../plugin/pluto_pagination_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<PlutoGridStateManager>(returnNullOnMissingStub: true),
])
void main() {
  MockPlutoGridStateManager? stateManager;

  setUp(() {
    stateManager = MockPlutoGridStateManager();
    when(stateManager!.configuration).thenReturn(
      const PlutoGridConfiguration(),
    );
  });

  group('렌더링', () {
    final buildWidget = ({
      int page = 1,
      int totalPage = 1,
    }) {
      return PlutoWidgetTestHelper('Tap cell', (tester) async {
        when(stateManager!.page).thenReturn(page);
        when(stateManager!.totalPage).thenReturn(totalPage);

        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PlutoPagination(stateManager!),
            ),
          ),
        );
      });
    };

    buildWidget().test(
      '페이지 번호 1이 렌더링 되어야 한다.',
      (tester) async {
        expect(find.text('1'), findsOneWidget);
      },
    );

    buildWidget().test(
      'ElevatedButton 이 4개 렌더링 되어야 한다. (처음, 이전, 다음, 마지막 버튼)',
      (tester) async {
        expect(find.byType(ElevatedButton), findsNWidgets(4));
      },
    );

    buildWidget(totalPage: 3).test(
      'totalPage 가 3인 경우 TextButton 이 3개 렌더링 되어야 한다.',
      (tester) async {
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(3));
      },
    );
  });
}
