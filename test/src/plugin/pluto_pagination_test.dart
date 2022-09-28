import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:rxdart/rxdart.dart';

import '../../helper/pluto_widget_test_helper.dart';
import '../../helper/test_helper_util.dart';
import '../../mock/shared_mocks.mocks.dart';

void main() {
  MockPlutoGridStateManager? stateManager;

  late PublishSubject<PlutoNotifierEvent> subject;

  setUp(() {
    stateManager = MockPlutoGridStateManager();
    subject = PublishSubject<PlutoNotifierEvent>();

    when(stateManager!.configuration).thenReturn(
      const PlutoGridConfiguration(),
    );

    when(stateManager!.footerHeight).thenReturn(45);

    when(stateManager!.streamNotifier).thenAnswer((_) => subject);
  });

  tearDown(() {
    subject.close();
  });

  group('렌더링', () {
    buildWidget({
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
    }

    buildWidget().test(
      '페이지 번호 1이 렌더링 되어야 한다.',
      (tester) async {
        expect(find.text('1'), findsOneWidget);
      },
    );

    buildWidget().test(
      'IconButton 이 4개 렌더링 되어야 한다. (처음, 이전, 다음, 마지막 버튼)',
      (tester) async {
        expect(find.byType(IconButton), findsNWidgets(4));
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

    buildWidget(
      totalPage: 10,
    ).test(
      '넓이가 449 이면 totalPage 가 10인 경우 TextButton 가 1개 렌더링 되어야 한다.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 449,
          height: PlutoGridSettings.rowHeight,
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(1));
      },
    );

    buildWidget(
      totalPage: 10,
    ).test(
      '넓이가 450 이면 totalPage 가 10인 경우 TextButton 가 3개 렌더링 되어야 한다.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 450,
          height: PlutoGridSettings.rowHeight,
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(3));
      },
    );

    buildWidget(
      totalPage: 10,
    ).test(
      '넓이가 549 이면 totalPage 가 10인 경우 TextButton 가 3개 렌더링 되어야 한다.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 549,
          height: PlutoGridSettings.rowHeight,
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(3));
      },
    );

    buildWidget(
      totalPage: 10,
    ).test(
      '넓이가 550 이면 totalPage 가 10인 경우 TextButton 가 5개 렌더링 되어야 한다.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 550,
          height: PlutoGridSettings.rowHeight,
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(5));
      },
    );

    buildWidget(
      totalPage: 10,
    ).test(
      '넓이가 649 이면 totalPage 가 10인 경우 TextButton 가 5개 렌더링 되어야 한다.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 649,
          height: PlutoGridSettings.rowHeight,
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(5));
      },
    );

    buildWidget(
      totalPage: 10,
    ).test(
      '넓이가 650 이면 totalPage 가 10인 경우 TextButton 가 7개 렌더링 되어야 한다.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 650,
          height: PlutoGridSettings.rowHeight,
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('6'), findsOneWidget);
        expect(find.text('7'), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(7));
      },
    );

    buildWidget(
      totalPage: 10,
    ).test(
      '넓이가 1280 이면 totalPage 가 10인 경우 TextButton 가 7개 렌더링 되어야 한다.',
      (tester) async {
        await TestHelperUtil.changeWidth(
          tester: tester,
          width: 1280,
          height: PlutoGridSettings.rowHeight,
        );

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('6'), findsOneWidget);
        expect(find.text('7'), findsOneWidget);
        expect(find.byType(TextButton), findsNWidgets(7));
      },
    );
  });
}
