import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  group(
    'PlutoColumnTextAlign',
    () {
      test(
        'isLeft',
        () {
          // given
          final PlutoColumnTextAlign textAlign = PlutoColumnTextAlign.left;
          // when
          // then
          expect(textAlign.isLeft, isTrue);
        },
      );

      test(
        'isRight',
        () {
          // given
          final PlutoColumnTextAlign textAlign = PlutoColumnTextAlign.right;
          // when
          // then
          expect(textAlign.isRight, isTrue);
        },
      );

      test(
        'value is TextAlign.left',
        () {
          // given
          final PlutoColumnTextAlign textAlign = PlutoColumnTextAlign.left;
          // when
          // then
          expect(textAlign.value, TextAlign.left);
        },
      );

      test(
        'value is TextAlign.right',
        () {
          // given
          final PlutoColumnTextAlign textAlign = PlutoColumnTextAlign.right;
          // when
          // then
          expect(textAlign.value, TextAlign.right);
        },
      );
    },
  );

  group(
    'PlutoColumnSort',
    () {
      test(
        'isNone',
        () {
          // given
          final PlutoColumnSort columnSort = PlutoColumnSort.none;
          // when
          // then
          expect(columnSort.isNone, isTrue);
        },
      );

      test(
        'isAscending',
        () {
          // given
          final PlutoColumnSort columnSort = PlutoColumnSort.ascending;
          // when
          // then
          expect(columnSort.isAscending, isTrue);
        },
      );

      test(
        'isDescending',
        () {
          // given
          final PlutoColumnSort columnSort = PlutoColumnSort.descending;
          // when
          // then
          expect(columnSort.isDescending, isTrue);
        },
      );

      group(
        'toShortString',
        () {
          test(
            'None',
            () {
              final PlutoColumnSort columnSort = PlutoColumnSort.none;
              expect(columnSort.toShortString(), 'none');
            },
          );

          test(
            'Ascending',
            () {
              final PlutoColumnSort columnSort = PlutoColumnSort.ascending;
              expect(columnSort.toShortString(), 'ascending');
            },
          );

          test(
            'Descending',
            () {
              final PlutoColumnSort columnSort = PlutoColumnSort.descending;
              expect(columnSort.toShortString(), 'descending');
            },
          );
        },
      );

      group(
        'fromString',
        () {
          test(
            'None',
            () {
              expect(PlutoColumnSort.none.fromString('none'),
                  PlutoColumnSort.none);
            },
          );

          test(
            'Ascending',
            () {
              expect(PlutoColumnSort.none.fromString('ascending'),
                  PlutoColumnSort.ascending);
            },
          );

          test(
            'Descending',
            () {
              expect(PlutoColumnSort.none.fromString('descending'),
                  PlutoColumnSort.descending);
            },
          );
        },
      );
    },
  );

  group('PlutoColumnTypeText 의 defaultValue', () {
    test(
      'text 기본 값이 설정 되어야 한다.',
      () {
        final PlutoColumnTypeText column = PlutoColumnType.text(
          defaultValue: 'default',
        );

        expect(column.defaultValue, 'default');
      },
    );

    test(
      'number 기본 값이 설정 되어야 한다.',
      () {
        final PlutoColumnTypeNumber column = PlutoColumnType.number(
          defaultValue: 123,
        );

        expect(column.defaultValue, 123);
      },
    );

    test(
      'select 기본 값이 설정 되어야 한다.',
      () {
        final PlutoColumnTypeSelect column = PlutoColumnType.select(
          ['One'],
          defaultValue: 'One',
        );

        expect(column.defaultValue, 'One');
      },
    );

    test(
      'date 기본 값이 설정 되어야 한다.',
      () {
        final PlutoColumnTypeDate column = PlutoColumnType.date(
          defaultValue: DateTime.parse('2020-01-01'),
        );

        expect(column.defaultValue, DateTime.parse('2020-01-01'));
      },
    );

    test(
      'time 기본 값이 설정 되어야 한다.',
      () {
        final PlutoColumnTypeTime column = PlutoColumnType.time(
          defaultValue: '20:30',
        );

        expect(column.defaultValue, '20:30');
      },
    );
  });

  group(
    'PlutoColumnTypeText',
    () {
      test(
        'text',
        () {
          final PlutoColumnTypeText textColumn = PlutoColumnType.text();
          expect(textColumn.text, textColumn);
        },
      );

      test(
        'time',
        () {
          final PlutoColumnTypeText textColumn = PlutoColumnType.text();
          expect(() {
            textColumn.time;
          }, throwsA(isA<TypeError>()));
        },
      );

      group(
        'isValid',
        () {
          test(
            '문자인 경우 true',
            () {
              final PlutoColumnTypeText textColumn = PlutoColumnType.text();
              expect(textColumn.isValid('text'), isTrue);
            },
          );

          test(
            '숫자인 경우 true',
            () {
              final PlutoColumnTypeText textColumn = PlutoColumnType.text();
              expect(textColumn.isValid(1234), isTrue);
            },
          );

          test(
            '공백인 경우 true',
            () {
              final PlutoColumnTypeText textColumn = PlutoColumnType.text();
              expect(textColumn.isValid(''), isTrue);
            },
          );

          test(
            'null 인 경우 false',
            () {
              final PlutoColumnTypeText textColumn = PlutoColumnType.text();
              expect(textColumn.isValid(null), isFalse);
            },
          );
        },
      );

      group(
        'compare',
        () {
          test(
            '가, 나 인 경우 -1',
            () {
              final PlutoColumnTypeText textColumn = PlutoColumnType.text();
              expect(textColumn.compare('가', '나'), -1);
            },
          );

          test(
            '나, 가 인 경우 1',
            () {
              final PlutoColumnTypeText textColumn = PlutoColumnType.text();
              expect(textColumn.compare('나', '가'), 1);
            },
          );

          test(
            '가, 가 인 경우 0',
            () {
              final PlutoColumnTypeText textColumn = PlutoColumnType.text();
              expect(textColumn.compare('가', '가'), 0);
            },
          );
        },
      );
    },
  );

  group('PlutoColumnTypeNumber', () {
    group('isValid', () {
      test(
        '문자인 경우 false',
        () {
          final PlutoColumnTypeNumber numberColumn = PlutoColumnType.number();
          expect(numberColumn.isValid('text'), isFalse);
        },
      );

      test(
        '123 인 경우 true',
        () {
          final PlutoColumnTypeNumber numberColumn = PlutoColumnType.number();
          expect(numberColumn.isValid(123), isTrue);
        },
      );

      test(
        '-123 인 경우 true',
        () {
          final PlutoColumnTypeNumber numberColumn = PlutoColumnType.number();
          expect(numberColumn.isValid(-123), isTrue);
        },
      );

      test(
        'negative 가 false 이고 -123 인 경우 false',
        () {
          final PlutoColumnTypeNumber numberColumn = PlutoColumnType.number(
            negative: false,
          );
          expect(numberColumn.isValid(-123), isFalse);
        },
      );
    });

    group(
      'compare',
      () {
        test(
          '1, 2 인 경우 -1',
          () {
            final PlutoColumnTypeNumber column = PlutoColumnType.number();
            expect(column.compare(1, 2), -1);
          },
        );

        test(
          '2, 1 인 경우 1',
          () {
            final PlutoColumnTypeNumber column = PlutoColumnType.number();
            expect(column.compare(2, 1), 1);
          },
        );

        test(
          '1, 1 인 경우 0',
          () {
            final PlutoColumnTypeNumber column = PlutoColumnType.number();
            expect(column.compare(1, 1), 0);
          },
        );
      },
    );
  });

  group('PlutoColumnTypeSelect', () {
    group('isValid', () {
      test(
        'items 에 포함 되어있으면 true',
        () {
          final PlutoColumnTypeSelect selectColumn = PlutoColumnType.select([
            'A',
            'B',
            'C',
          ]);
          expect(selectColumn.isValid('A'), isTrue);
        },
      );

      test(
        'items 에 포함 되어 있지 않으면 false',
        () {
          final PlutoColumnTypeSelect selectColumn = PlutoColumnType.select([
            'A',
            'B',
            'C',
          ]);
          expect(selectColumn.isValid('D'), isFalse);
        },
      );
    });

    group(
      'compare',
      () {
        test(
          'Two, Three 인 경우 -1',
          () {
            final PlutoColumnTypeSelect column = PlutoColumnType.select([
              'One',
              'Two',
              'Three',
            ]);
            expect(column.compare('Two', 'Three'), -1);
          },
        );

        test(
          'Three, Two  인 경우 1',
          () {
            final PlutoColumnTypeSelect column = PlutoColumnType.select([
              'One',
              'Two',
              'Three',
            ]);
            expect(column.compare('Three', 'Two'), 1);
          },
        );

        test(
          'Two, Two 인 경우 0',
          () {
            final PlutoColumnTypeSelect column = PlutoColumnType.select([
              'One',
              'Two',
              'Three',
            ]);
            expect(column.compare('Two', 'Two'), 0);
          },
        );
      },
    );
  });

  group('PlutoColumnTypeDate', () {
    group('isValid', () {
      test(
        '날짜 형식이 아니면 false',
        () {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date();
          expect(dateColumn.isValid('Not a date'), isFalse);
        },
      );

      test(
        '날짜 형식이면 true',
        () {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date();
          expect(dateColumn.isValid('2020-01-01'), isTrue);
        },
      );

      test(
        '시작일이 있는 경우 시작일 보다 작으면 false',
        () {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            startDate: DateTime.parse('2020-02-01'),
          );
          expect(dateColumn.isValid('2020-01-01'), isFalse);
        },
      );

      test(
        '시작일이 있는 경우 시작일과 같으면 true',
        () {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            startDate: DateTime.parse('2020-02-01'),
          );
          expect(dateColumn.isValid('2020-02-01'), isTrue);
        },
      );

      test(
        '시작일이 있는 경우 시작일보다 크면 true',
        () {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            startDate: DateTime.parse('2020-02-01'),
          );
          expect(dateColumn.isValid('2020-02-03'), isTrue);
        },
      );

      test(
        '마지막일이 있는 경우 마지막일보다 작으면 true',
        () {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            endDate: DateTime.parse('2020-02-01'),
          );
          expect(dateColumn.isValid('2020-01-01'), isTrue);
        },
      );

      test(
        '마지막일이 있는 경우 마지막일과 같으면 true',
        () {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            endDate: DateTime.parse('2020-02-01'),
          );
          expect(dateColumn.isValid('2020-02-01'), isTrue);
        },
      );

      test(
        '마지막일이 있는 경우 마지막일보다 크면 false',
        () {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            endDate: DateTime.parse('2020-02-01'),
          );
          expect(dateColumn.isValid('2020-02-03'), isFalse);
        },
      );

      test(
        '시작일과 마지막일이 둘다 있는 경우 범위에 있으면 true',
        () {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            startDate: DateTime.parse('2020-02-01'),
            endDate: DateTime.parse('2020-02-05'),
          );
          expect(dateColumn.isValid('2020-02-03'), isTrue);
        },
      );

      test(
        '시작일과 마지막일이 둘다 있는 경우 범위보다 작으면 false',
        () {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            startDate: DateTime.parse('2020-02-01'),
            endDate: DateTime.parse('2020-02-05'),
          );
          expect(dateColumn.isValid('2020-01-03'), isFalse);
        },
      );

      test(
        '시작일과 마지막일이 둘다 있는 경우 범위보다 크면 false',
        () {
          final PlutoColumnTypeDate dateColumn = PlutoColumnType.date(
            startDate: DateTime.parse('2020-02-01'),
            endDate: DateTime.parse('2020-02-05'),
          );
          expect(dateColumn.isValid('2020-02-06'), isFalse);
        },
      );
    });

    group(
      'compare',
      () {
        test(
          '2019-12-30, 2020-01-01 인 경우 -1',
          () {
            final PlutoColumnTypeDate column = PlutoColumnType.date();
            expect(column.compare('2019-12-30', '2020-01-01'), -1);
          },
        );

        // 날짜 포멧이 적용 된 경우 컬럼의 compare 함수의 동작이 의도와 다르다.
        // 포멧을 바꿔 compare 함수를 호출해야 한다. compare 함수는 포멧을 적당하게
        // 변환하여 호출하고 포멧의 변경은 외부에서 호출 할 때 처리 한다.
        test(
          '12/30/2019, 01/01/2020 인 경우 1',
          () {
            final PlutoColumnTypeDate column =
                PlutoColumnType.date(format: 'MM/dd/yyyy');
            expect(column.compare('12/30/2019', '01/01/2020'), 1);
          },
        );

        test(
          '2020-01-01, 2019-12-30  인 경우 1',
          () {
            final PlutoColumnTypeDate column = PlutoColumnType.date();
            expect(column.compare('2020-01-01', '2019-12-30'), 1);
          },
        );

        // 날짜 포멧이 적용 된 경우 컬럼의 compare 함수의 동작이 의도와 다르다.
        // 포멧을 바꿔 compare 함수를 호출해야 한다. compare 함수는 포멧을 적당하게
        // 변환하여 호출하고 포멧의 변경은 외부에서 호출 할 때 처리 한다.
        test(
          '01/01/2020, 12/30/2019  인 경우 -1',
          () {
            final PlutoColumnTypeDate column =
                PlutoColumnType.date(format: 'MM/dd/yyyy');
            expect(column.compare('01/01/2020', '12/30/2019'), -1);
          },
        );

        test(
          '2020-01-01, 2020-01-01 인 경우 0',
          () {
            final PlutoColumnTypeDate column = PlutoColumnType.date();
            expect(column.compare('2020-01-01', '2020-01-01'), 0);
          },
        );

        test(
          '01/01/2020, 01/01/2020  인 경우 0',
          () {
            final PlutoColumnTypeDate column =
                PlutoColumnType.date(format: 'MM/dd/yyyy');
            expect(column.compare('01/01/2020', '01/01/2020'), 0);
          },
        );
      },
    );
  });

  group(
    'PlutoColumnTypeTime',
    () {
      group('isValid', () {
        test(
          '24:00 이면 false',
          () {
            final PlutoColumnTypeTime timeColumn = PlutoColumnType.time();
            expect(timeColumn.isValid('24:00'), isFalse);
          },
        );

        test(
          '00:60 이면 false',
          () {
            final PlutoColumnTypeTime timeColumn = PlutoColumnType.time();
            expect(timeColumn.isValid('00:60'), isFalse);
          },
        );

        test(
          '24:60 이면 false',
          () {
            final PlutoColumnTypeTime timeColumn = PlutoColumnType.time();
            expect(timeColumn.isValid('24:60'), isFalse);
          },
        );

        test(
          '00:00 이면 true',
          () {
            final PlutoColumnTypeTime timeColumn = PlutoColumnType.time();
            expect(timeColumn.isValid('00:00'), isTrue);
          },
        );

        test(
          '00:59 이면 true',
          () {
            final PlutoColumnTypeTime timeColumn = PlutoColumnType.time();
            expect(timeColumn.isValid('00:59'), isTrue);
          },
        );

        test(
          '23:00 이면 true',
          () {
            final PlutoColumnTypeTime timeColumn = PlutoColumnType.time();
            expect(timeColumn.isValid('23:00'), isTrue);
          },
        );

        test(
          '23:59 이면 true',
          () {
            final PlutoColumnTypeTime timeColumn = PlutoColumnType.time();
            expect(timeColumn.isValid('23:59'), isTrue);
          },
        );
      });
    },
  );

  group('formattedValueForType', () {
    test(
      'Number column 인 경우 12345 값이 12,345 로 포멧이 적용 되어야 한다.',
      () {
        final PlutoColumn column = PlutoColumn(
          title: 'number column',
          field: 'number_column',
          type: PlutoColumnType.number(), // 기본 포멧 (#,###)
        );

        expect(column.formattedValueForType(12345), '12,345');
      },
    );

    test(
      'Number column 인 경우 12345678 값이 12,345,678 로 포멧이 적용 되어야 한다.',
      () {
        final PlutoColumn column = PlutoColumn(
          title: 'number column',
          field: 'number_column',
          type: PlutoColumnType.number(), // 기본 포멧 (#,###)
        );

        expect(column.formattedValueForType(12345678), '12,345,678');
      },
    );

    test(
      'Number column 이 아닌 경우 12345 값이 12345 로 포멧이 적용 되지 않아야 한다.',
      () {
        final PlutoColumn column = PlutoColumn(
          title: 'number column',
          field: 'number_column',
          type: PlutoColumnType.text(), // 기본 포멧 (#,###)
        );

        expect(column.formattedValueForType('12345'), '12345');
      },
    );
  });

  group('formattedValueForDisplay', () {
    test(
      'formatter 가 없는 경우 Number column 의 타입에 대한 포멧만 적용되어야 한다.',
      () {
        final PlutoColumn column = PlutoColumn(
          title: 'number column',
          field: 'number_column',
          type: PlutoColumnType.number(), // 기본 포멧 (#,###)
        );

        expect(column.formattedValueForDisplay(12345), '12,345');
      },
    );

    test(
      'formatter 가 있는 경우 Number column 의 타입에 대한 포멧이 아닌 '
      'formatter 가 적용 되어야 한다.',
      () {
        final PlutoColumn column = PlutoColumn(
          title: 'number column',
          field: 'number_column',
          type: PlutoColumnType.number(), // 기본 포멧 (#,###)
          formatter: (dynamic value) => '\$ $value',
        );

        expect(column.formattedValueForDisplay(12345), '\$ 12345');
      },
    );
  });
}
