import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../helper/pluto_widget_test_helper.dart';
import '../matcher/pluto_object_matcher.dart';
import '../mock/mock_on_change_listener.dart';

final now = DateTime.now();

final mockListener = MockOnChangeListener();

void main() {
  buildPopup({
    required String format,
    required String headerFormat,
    DateTime? initDate,
    DateTime? startDate,
    DateTime? endDate,
    PlutoOnLoadedEventCallback? onLoaded,
    PlutoOnSelectedEventCallback? onSelected,
    double? itemHeight,
    PlutoGridConfiguration? configuration,
  }) {
    final _dateFormat = intl.DateFormat(format);

    final _headerFormat = intl.DateFormat(headerFormat);

    return PlutoWidgetTestHelper('Build date picker.', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Builder(
              builder: (BuildContext context) {
                return TextButton(
                  onPressed: () {
                    PlutoGridDatePicker(
                      context: context,
                      dateFormat: _dateFormat,
                      headerDateFormat: _headerFormat,
                      initDate: initDate,
                      startDate: startDate,
                      endDate: endDate,
                      onLoaded: onLoaded,
                      onSelected: onSelected,
                      itemHeight:
                          itemHeight ?? PlutoGridSettings.rowTotalHeight,
                      configuration:
                          configuration ?? const PlutoGridConfiguration(),
                    );
                  },
                  child: const Text('open date picker'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextButton));

      await tester.pumpAndSettle();
    });
  }

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
  ).test(
    '높이와 넓이를 충족하는 위젯이 생성 되어야 한다.',
    (tester) async {
      final size = tester.getSize(find.byType(PlutoGrid));

      // 45 : 기본 행 넓이, 7 : 월~일
      expect(size.width, greaterThan(45 * 7));

      // 6주의 행을 보여준다.
      double rowsHeight = 6 * PlutoGridSettings.rowTotalHeight;

      // itemHeight * 2 = Header Height + Column Height
      double popupHeight = (PlutoGridSettings.rowTotalHeight * 2) +
          rowsHeight +
          PlutoGridSettings.totalShadowLineWidth +
          PlutoGridSettings.gridInnerSpacing;

      expect(size.height, popupHeight);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
  ).test(
    '년,월을 변경하는 IconButton 이 출력 되어야 한다.',
    (tester) async {
      expect(find.byType(IconButton), findsNWidgets(4));
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
  ).test(
    'initDate, startDate, endDate 를 전달 하지 않은 경우, '
    '현재 달이 출력 되어야 한다.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentYearMonth = headerFormat.format(now);

      const firstDay = '1';

      expect(find.text(currentYearMonth), findsOneWidget);

      expect(find.text(firstDay), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    startDate: DateTime(2022, 5, 10),
  ).test(
    'startDate 를 설정한 경우 해당 월이 출력 되어야 한다.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentYearMonth = headerFormat.format(DateTime(2022, 5, 10));

      expect(find.text(currentYearMonth), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(now.year, now.month, 20),
  ).test(
    'initDate 를 설정한 경우 해당 날짜가 선택 되어야 한다.',
    (tester) async {
      const selectedDay = '20';

      final selectedDayText = find.text(selectedDay).first;

      final selectedDayTextWidget =
          selectedDayText.first.evaluate().first.widget as Text;

      final selectedDayTextStyle = selectedDayTextWidget.style as TextStyle;

      expect(selectedDayText, findsOneWidget);

      expect(selectedDayTextStyle.color, Colors.white);

      final selectedDayWidget = find
          .ancestor(
            of: selectedDayText,
            matching: find.byType(Container),
          )
          .first;

      final selectedDayContainer =
          selectedDayWidget.first.evaluate().first.widget as Container;

      final decoration = selectedDayContainer.decoration as BoxDecoration;

      expect(selectedDayWidget, findsOneWidget);

      expect(decoration.color, Colors.lightBlue);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
  ).test(
    '현재 달에서 1일을 선택하고 키보드 방향키 위를 누르면, '
    '이전 달이 출력 되어야 한다.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentMonthYear = headerFormat.format(now);

      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.tap(find.text('1'));

      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowUp);

      await tester.pump();

      final expectDate = DateTime(now.year, now.month - 1);

      final expectMonthYear = headerFormat.format(expectDate);

      expect(find.text(expectMonthYear), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 30),
  ).test(
    '2022.6.30 일을 선택하고 키보드 방향키 아래를 입력하면, '
    '다음 달이 출력 되어야 한다.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentMonthYear = headerFormat.format(DateTime(2022, 6, 30));

      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);

      await tester.pump();

      final expectDate = DateTime(now.year, now.month + 1);

      final expectMonthYear = headerFormat.format(expectDate);

      expect(find.text(expectMonthYear), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 5),
  ).test(
    '2022.6.5 일을 선택하고 키보드 방향키 왼쪽을 입력하면, '
    '이전 년이 출력 되어야 한다.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentMonthYear = headerFormat.format(DateTime(2022, 6, 5));

      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);

      await tester.pump();

      final expectDate = DateTime(now.year, now.month - 12);

      final expectMonthYear = headerFormat.format(expectDate);

      expect(find.text(expectMonthYear), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 11),
  ).test(
    '2022.6.11 일을 선택하고 키보드 방향키 오른쪽을 입력하면, '
    '다음 년이 출력 되어야 한다.',
    (tester) async {
      final headerFormat = intl.DateFormat('yyyy-MM');

      final currentMonthYear = headerFormat.format(DateTime(2022, 6, 11));

      expect(find.text(currentMonthYear), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);

      await tester.pump();

      final expectDate = DateTime(now.year, now.month + 12);

      final expectMonthYear = headerFormat.format(expectDate);

      expect(find.text(expectMonthYear), findsOneWidget);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 11),
    onSelected: mockListener.onChangeOneParamListener<PlutoGridOnSelectedEvent>,
  ).test(
    '2022.6.11 일을 선택하고 탭하면, '
    'onSelected 콜백이 호출 되어야 한다.',
    (tester) async {
      await tester.tap(find.text('11'));

      await tester.pump();

      verify(
        mockListener.onChangeOneParamListener(argThat(
            PlutoObjectMatcher<PlutoGridOnSelectedEvent>(rule: (object) {
          return object.cell!.value == '2022-06-11';
        }))),
      ).called(1);
    },
  );

  buildPopup(
    format: 'yyyy-MM-dd',
    headerFormat: 'yyyy-MM',
    initDate: DateTime(2022, 6, 11),
    onLoaded: mockListener.onChangeOneParamListener<PlutoGridOnLoadedEvent>,
  ).test(
    '2022.6.11 일을 선택하고 탭하면, '
    'onSelected 콜백이 호출 되어야 한다.',
    (tester) async {
      await tester.tap(find.text('11'));

      await tester.pump();

      verify(
        mockListener.onChangeOneParamListener(
          argThat(
            isA<PlutoGridOnLoadedEvent>(),
          ),
        ),
      ).called(1);
    },
  );
}
