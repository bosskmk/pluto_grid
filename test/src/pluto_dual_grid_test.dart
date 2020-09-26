import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../helper/column_helper.dart';
import '../helper/row_helper.dart';

void main() {
  testWidgets('두개의 그리드가 생성 되고 셀이 출력 되어야 한다.', (WidgetTester tester) async {
    // given
    final gridAColumns = ColumnHelper.textColumn('headerA');
    final gridARows = RowHelper.count(3, gridAColumns);

    final gridBColumns = ColumnHelper.textColumn('headerB');
    final gridBRows = RowHelper.count(3, gridBColumns);

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: Container(
            child: PlutoDualGrid(
              gridPropsA: PlutoDualGridProps(
                columns: gridAColumns,
                rows: gridARows,
              ),
              gridPropsB: PlutoDualGridProps(
                columns: gridBColumns,
                rows: gridBRows,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // then
    final gridACell1 = find.text('headerA0 value 0');
    expect(gridACell1, findsOneWidget);

    final gridACell2 = find.text('headerA0 value 1');
    expect(gridACell2, findsOneWidget);

    final gridACell3 = find.text('headerA0 value 2');
    expect(gridACell3, findsOneWidget);

    final gridBCell1 = find.text('headerB0 value 0');
    expect(gridBCell1, findsOneWidget);

    final gridBCell2 = find.text('headerB0 value 1');
    expect(gridBCell2, findsOneWidget);

    final gridBCell3 = find.text('headerB0 value 2');
    expect(gridBCell3, findsOneWidget);
  });
}
