import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  group(
    'PlutoColumnSort',
    () {
      testWidgets(
        'isNone',
        (WidgetTester tester) async {
          // given
          final PlutoColumnSort columnSort = PlutoColumnSort.None;
          // when
          // then
          expect(columnSort.isNone, isTrue);
        },
      );

      testWidgets(
        'isAscending',
        (WidgetTester tester) async {
          // given
          final PlutoColumnSort columnSort = PlutoColumnSort.Ascending;
          // when
          // then
          expect(columnSort.isAscending, isTrue);
        },
      );

      testWidgets(
        'isDescending',
        (WidgetTester tester) async {
          // given
          final PlutoColumnSort columnSort = PlutoColumnSort.Descending;
          // when
          // then
          expect(columnSort.isDescending, isTrue);
        },
      );

      group(
        'toShortString',
        () {
          testWidgets(
            'None',
            (WidgetTester tester) async {
              final PlutoColumnSort columnSort = PlutoColumnSort.None;
              expect(columnSort.toShortString(), 'None');
            },
          );

          testWidgets(
            'Ascending',
            (WidgetTester tester) async {
              final PlutoColumnSort columnSort = PlutoColumnSort.Ascending;
              expect(columnSort.toShortString(), 'Ascending');
            },
          );

          testWidgets(
            'Descending',
            (WidgetTester tester) async {
              final PlutoColumnSort columnSort = PlutoColumnSort.Descending;
              expect(columnSort.toShortString(), 'Descending');
            },
          );
        },
      );

      group(
        'fromString',
        () {
          testWidgets(
            'None',
            (WidgetTester tester) async {
              expect(PlutoColumnSort.None.fromString('None'),
                  PlutoColumnSort.None);
            },
          );

          testWidgets(
            'Ascending',
            (WidgetTester tester) async {
              expect(PlutoColumnSort.None.fromString('Ascending'),
                  PlutoColumnSort.Ascending);
            },
          );

          testWidgets(
            'Descending',
            (WidgetTester tester) async {
              expect(PlutoColumnSort.None.fromString('Descending'),
                  PlutoColumnSort.Descending);
            },
          );
        },
      );
    },
  );

  group(
    'PlutoColumnTypeText',
    () {
      testWidgets(
        'text',
        (WidgetTester tester) async {
          final PlutoColumnTypeText textColumn = PlutoColumnType.text();
          expect(textColumn.text, textColumn);
        },
      );

      testWidgets(
        'time',
        (WidgetTester tester) async {
          final PlutoColumnTypeText textColumn = PlutoColumnType.text();
          expect(() {
            final getInvalidColumn = textColumn.time;
          }, throwsA(isA<TypeError>()));
        },
      );

      group(
        'isValid',
        () {
          testWidgets(
            '문자인 경우 true',
            (WidgetTester tester) async {
              final PlutoColumnTypeText textColumn = PlutoColumnType.text();
              expect(textColumn.isValid('text'), isTrue);
            },
          );

          testWidgets(
            '숫자인 경우 true',
            (WidgetTester tester) async {
              final PlutoColumnTypeText textColumn = PlutoColumnType.text();
              expect(textColumn.isValid(1234), isTrue);
            },
          );

          testWidgets(
            '공백인 경우 true',
            (WidgetTester tester) async {
              final PlutoColumnTypeText textColumn = PlutoColumnType.text();
              expect(textColumn.isValid(''), isTrue);
            },
          );

          testWidgets(
            'null 인 경우 false',
            (WidgetTester tester) async {
              final PlutoColumnTypeText textColumn = PlutoColumnType.text();
              expect(textColumn.isValid(null), isFalse);
            },
          );
        },
      );
    },
  );

  group('PlutoColumnTypeNumber', () {
    group('isValid', () {
      testWidgets(
        '문자인 경우 false',
        (WidgetTester tester) async {
          final PlutoColumnTypeNumber numberColumn = PlutoColumnType.number();
          expect(numberColumn.isValid('text'), isFalse);
        },
      );

      testWidgets(
        '123 인 경우 true',
        (WidgetTester tester) async {
          final PlutoColumnTypeNumber numberColumn = PlutoColumnType.number();
          expect(numberColumn.isValid(123), isTrue);
        },
      );

      testWidgets(
        '-123 인 경우 true',
        (WidgetTester tester) async {
          final PlutoColumnTypeNumber numberColumn = PlutoColumnType.number();
          expect(numberColumn.isValid(-123), isTrue);
        },
      );

      testWidgets(
        'negative 가 false 이고 -123 인 경우 false',
        (WidgetTester tester) async {
          final PlutoColumnTypeNumber numberColumn = PlutoColumnType.number(
            negative: false,
          );
          expect(numberColumn.isValid(-123), isFalse);
        },
      );
    });
  });

  group('PlutoColumnTypeSelect', () {
    group('isValid', () {
      testWidgets(
        'items 에 포함 되어있으면 true',
        (WidgetTester tester) async {
          final PlutoColumnTypeSelect selectColumn = PlutoColumnType.select([
            'A',
            'B',
            'C',
          ]);
          expect(selectColumn.isValid('A'), isTrue);
        },
      );

      testWidgets(
        'items 에 포함 되어 있지 않으면 false',
            (WidgetTester tester) async {
          final PlutoColumnTypeSelect selectColumn = PlutoColumnType.select([
            'A',
            'B',
            'C',
          ]);
          expect(selectColumn.isValid('D'), isFalse);
        },
      );
    });
  });

  group('PlutoColumnTypeDate', () {
    group('isValid', () {
      testWidgets(
        '날짜 형식이 아니면 false',
            (WidgetTester tester) async {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date();
          expect(dateColumn.isValid('Not a date'), isFalse);
        },
      );

      testWidgets(
        '날짜 형식이면 true',
            (WidgetTester tester) async {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date();
          expect(dateColumn.isValid('2020-01-01'), isTrue);
        },
      );

      testWidgets(
        '시작일이 있는 경우 시작일 보다 작으면 false',
            (WidgetTester tester) async {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            startDate: DateTime.parse('2020-02-01'),
          );
          expect(dateColumn.isValid('2020-01-01'), isFalse);
        },
      );

      testWidgets(
        '시작일이 있는 경우 시작일과 같으면 true',
            (WidgetTester tester) async {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            startDate: DateTime.parse('2020-02-01'),
          );
          expect(dateColumn.isValid('2020-02-01'), isTrue);
        },
      );

      testWidgets(
        '시작일이 있는 경우 시작일보다 크면 true',
            (WidgetTester tester) async {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            startDate: DateTime.parse('2020-02-01'),
          );
          expect(dateColumn.isValid('2020-02-03'), isTrue);
        },
      );

      testWidgets(
        '마지막일이 있는 경우 마지막일보다 작으면 true',
            (WidgetTester tester) async {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            endDate: DateTime.parse('2020-02-01'),
          );
          expect(dateColumn.isValid('2020-01-01'), isTrue);
        },
      );

      testWidgets(
        '마지막일이 있는 경우 마지막일과 같으면 true',
            (WidgetTester tester) async {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            endDate: DateTime.parse('2020-02-01'),
          );
          expect(dateColumn.isValid('2020-02-01'), isTrue);
        },
      );

      testWidgets(
        '마지막일이 있는 경우 마지막일보다 크면 false',
            (WidgetTester tester) async {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            endDate: DateTime.parse('2020-02-01'),
          );
          expect(dateColumn.isValid('2020-02-03'), isFalse);
        },
      );

      testWidgets(
        '시작일과 마지막일이 둘다 있는 경우 범위에 있으면 true',
            (WidgetTester tester) async {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            startDate: DateTime.parse('2020-02-01'),
            endDate: DateTime.parse('2020-02-05'),
          );
          expect(dateColumn.isValid('2020-02-03'), isTrue);
        },
      );

      testWidgets(
        '시작일과 마지막일이 둘다 있는 경우 범위보다 작으면 false',
            (WidgetTester tester) async {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            startDate: DateTime.parse('2020-02-01'),
            endDate: DateTime.parse('2020-02-05'),
          );
          expect(dateColumn.isValid('2020-01-03'), isFalse);
        },
      );

      testWidgets(
        '시작일과 마지막일이 둘다 있는 경우 범위보다 크면 false',
            (WidgetTester tester) async {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            startDate: DateTime.parse('2020-02-01'),
            endDate: DateTime.parse('2020-02-05'),
          );
          expect(dateColumn.isValid('2020-02-06'), isFalse);
        },
      );
    });
  });

  group(
    'PlutoColumnTypeTime',
    () {
      group('isValid', () {
        testWidgets(
          '24:00 이면 false',
              (WidgetTester tester) async {
            final PlutoColumnTypeTime timeColumn = PlutoColumnType.time();
            expect(timeColumn.isValid('24:00'), isFalse);
          },
        );

        testWidgets(
          '00:60 이면 false',
              (WidgetTester tester) async {
            final PlutoColumnTypeTime timeColumn = PlutoColumnType.time();
            expect(timeColumn.isValid('00:60'), isFalse);
          },
        );

        testWidgets(
          '24:60 이면 false',
              (WidgetTester tester) async {
            final PlutoColumnTypeTime timeColumn = PlutoColumnType.time();
            expect(timeColumn.isValid('24:60'), isFalse);
          },
        );

        testWidgets(
          '00:00 이면 true',
              (WidgetTester tester) async {
            final PlutoColumnTypeTime timeColumn = PlutoColumnType.time();
            expect(timeColumn.isValid('00:00'), isTrue);
          },
        );

        testWidgets(
          '00:59 이면 true',
              (WidgetTester tester) async {
            final PlutoColumnTypeTime timeColumn = PlutoColumnType.time();
            expect(timeColumn.isValid('00:59'), isTrue);
          },
        );

        testWidgets(
          '23:00 이면 true',
              (WidgetTester tester) async {
            final PlutoColumnTypeTime timeColumn = PlutoColumnType.time();
            expect(timeColumn.isValid('23:00'), isTrue);
          },
        );

        testWidgets(
          '23:59 이면 true',
              (WidgetTester tester) async {
            final PlutoColumnTypeTime timeColumn = PlutoColumnType.time();
            expect(timeColumn.isValid('23:59'), isTrue);
          },
        );
      });
    },
  );
}
