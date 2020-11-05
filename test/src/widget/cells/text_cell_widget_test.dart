import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../mock/mock_pluto_state_manager.dart';

void main() {
  PlutoStateManager stateManager;

  setUp(() {
    stateManager = MockPlutoStateManager();
    when(stateManager.configuration).thenReturn(PlutoConfiguration());
    when(stateManager.localeText).thenReturn(PlutoGridLocaleText());
    when(stateManager.keepFocus).thenReturn(true);
    when(stateManager.hasFocus).thenReturn(true);
  });

  testWidgets('셀 값이 출력 되어야 한다.', (WidgetTester tester) async {
    // given
    final PlutoColumn column = PlutoColumn(
      title: 'column title',
      field: 'column_field_name',
      type: PlutoColumnType.text(),
    );

    final PlutoCell cell = PlutoCell(value: 'text value');

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TextCellWidget(
            stateManager: stateManager,
            cell: cell,
            column: column,
          ),
        ),
      ),
    );

    // then
    expect(find.text('text value'), findsOneWidget);
  });
}
