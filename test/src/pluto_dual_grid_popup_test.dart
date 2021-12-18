import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../helper/column_helper.dart';
import '../helper/row_helper.dart';

void main() {
  testWidgets('그리드 팝업이 호출 되고 셀 값이 출력 되어야 한다.', (WidgetTester tester) async {
    // given
    final gridAColumns = ColumnHelper.textColumn('headerA');
    final gridARows = RowHelper.count(3, gridAColumns);

    final gridBColumns = ColumnHelper.textColumn('headerB');
    final gridBRows = RowHelper.count(3, gridBColumns);

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Builder(
            builder: (BuildContext context) {
              return TextButton(
                onPressed: () {
                  PlutoDualGridPopup(
                    context: context,
                    gridPropsA: PlutoDualGridProps(
                      columns: gridAColumns,
                      rows: gridARows,
                    ),
                    gridPropsB: PlutoDualGridProps(
                      columns: gridBColumns,
                      rows: gridBRows,
                    ),
                  );
                },
                child: const Text('open grid popup'),
              );
            },
          ),
        ),
      ),
    );

    // when
    await tester.tap(find.byType(TextButton));

    await tester.pumpAndSettle();

    // then
    final gridACell1 = find.text('headerA0 value 0');
    expect(gridACell1, findsOneWidget);

    final gridBCell1 = find.text('headerB0 value 0');
    expect(gridBCell1, findsOneWidget);
  });
}
