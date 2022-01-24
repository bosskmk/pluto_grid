import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/pluto_widget_test_helper.dart';
import 'pluto_number_cell_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<PlutoGridStateManager>(returnNullOnMissingStub: true),
])
void main() {
  late PlutoGridStateManager stateManager;

  buildWidget({
    dynamic number = 0,
    bool negative = true,
    String format = '#,###',
    bool applyFormatOnInit = true,
    bool allowFirstDot = false,
  }) {
    return PlutoWidgetTestHelper('build number cell.', (tester) async {
      stateManager = MockPlutoGridStateManager();

      when(stateManager.configuration).thenReturn(
        const PlutoGridConfiguration(),
      );

      when(stateManager.keepFocus).thenReturn(true);

      final PlutoColumn column = PlutoColumn(
        title: 'column title',
        field: 'column_field_name',
        type: PlutoColumnType.number(
          negative: negative,
          format: format,
          applyFormatOnInit: applyFormatOnInit,
          allowFirstDot: allowFirstDot,
        ),
      );

      final PlutoCell cell = PlutoCell(value: number);

      final PlutoRow row = PlutoRow(
        cells: {
          'column_field_name': cell,
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: PlutoNumberCell(
              stateManager: stateManager,
              cell: cell,
              column: column,
              row: row,
            ),
          ),
        ),
      );
    });
  }

  buildWidget(
    number: 0,
    negative: true,
    format: '#,###',
    applyFormatOnInit: true,
    allowFirstDot: false,
  ).test(
    '기본값 0 이 출력 되어야 한다.',
    (tester) async {
      expect(find.text('0'), findsOneWidget);
    },
  );

  group('DecimalTextInputFormatter', () {
    updatedValue({
      required String oldValue,
      required String newValue,
      required int decimalRange,
      required bool activatedNegativeValues,
      required bool allowFirstDot,
    }) {
      final oldText = TextEditingValue(text: oldValue);

      final newText = TextEditingValue(text: newValue);

      final formatter = DecimalTextInputFormatter(
        decimalRange: decimalRange,
        activatedNegativeValues: activatedNegativeValues,
        allowFirstDot: allowFirstDot,
      );

      return formatter.formatEditUpdate(oldText, newText).text;
    }

    test(
      'decimalRange 가 2 인 상태에서 0.12 을 입력하면 0.12 가 리턴 되어야 한다.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '0.12',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: false,
          ),
          '0.12',
        );
      },
    );

    test(
      'decimalRange 가 2 인 상태에서 0.123 을 입력하면 0 이 리턴 되어야 한다.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '0.123',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: false,
          ),
          '0',
        );
      },
    );

    test(
      'activatedNegativeValues 가 true 인 상태에서 -0.12 을 입력하면 -0.12 이 리턴 되어야 한다.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '-0.12',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: false,
          ),
          '-0.12',
        );
      },
    );

    test(
      'activatedNegativeValues 가 false 인 상태에서 -0.12 을 입력하면 0 이 리턴 되어야 한다.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '-0.12',
            decimalRange: 2,
            activatedNegativeValues: false,
            allowFirstDot: false,
          ),
          '0',
        );
      },
    );

    test(
      'activatedNegativeValues 가 true, allowFirstDot 이 false 인 상태에서, '
      '.0.12 을 입력하면 0 이 리턴 되어야 한다.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '.0.12',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: false,
          ),
          '0',
        );
      },
    );

    test(
      'activatedNegativeValues 가 true, allowFirstDot 이 true 인 상태에서, '
      '.0.12 을 입력하면 .0.12 가 리턴 되어야 한다.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '.0.12',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: true,
          ),
          '.0.12',
        );
      },
    );

    test(
      'activatedNegativeValues 가 true, allowFirstDot 이 true 인 상태에서, '
      '..0.12 을 입력하면 0 가 리턴 되어야 한다.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '..0.12',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: true,
          ),
          '0',
        );
      },
    );

    test(
      'activatedNegativeValues 가 true, allowFirstDot 이 true 인 상태에서, '
      '-.0.12 을 입력하면 0 가 리턴 되어야 한다.',
      () {
        expect(
          updatedValue(
            oldValue: '0',
            newValue: '-.0.12',
            decimalRange: 2,
            activatedNegativeValues: true,
            allowFirstDot: true,
          ),
          '0',
        );
      },
    );
  });
}
