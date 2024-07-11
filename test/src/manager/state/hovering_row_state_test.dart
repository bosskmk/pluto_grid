import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/mock_methods.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  late List<PlutoColumn> columns;

  late List<PlutoRow> rows;

  late PlutoGridStateManager stateManager;

  MockMethods? listener;

  setUp(() {
    columns = [
      ...ColumnHelper.textColumn('column', count: 1, width: 150),
    ];

    rows = RowHelper.count(10, columns);

    stateManager = PlutoGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: MockFocusNode(),
      scroll: MockPlutoGridScrollController(),
    );

    listener = MockMethods();

    stateManager.addListener(listener!.noParamReturnVoid);
  });

  group('setHoveredRowIdx', () {
    test(
      'If the rowIdx passed as an argument is the same as'
          'hoveredRowIdx, then notifyListeners should not be called.',
      () {
        // given
        stateManager.setHoveredRowIdx(1);
        expect(stateManager.hoveredRowIdx, 1);

        // when
        clearInteractions(listener);
        stateManager.setHoveredRowIdx(1);

        // then
        verifyNever(listener!.noParamReturnVoid());
      },
    );

    test(
      'If the rowIdx passed as an argument is different from '
          'hoveredRowIdx, notifyListeners should be called.',
      () {
        // given
        stateManager.setHoveredRowIdx(1);
        expect(stateManager.hoveredRowIdx, 1);

        // when
        clearInteractions(listener);
        stateManager.setHoveredRowIdx(2);

        // then
        expect(stateManager.hoveredRowIdx, 2);
        verify(listener!.noParamReturnVoid()).called(1);
      },
    );

    test(
      'If the rowIdx passed as an argument is different from '
          'hoveredRowIdx, but notify is false,'
          'notifyListeners should not be called.',
      () {
        // given
        stateManager.setHoveredRowIdx(1);
        expect(stateManager.hoveredRowIdx, 1);

        // when
        clearInteractions(listener);
        stateManager.setHoveredRowIdx(2, notify: false);

        // then
        expect(stateManager.hoveredRowIdx, 2);
        verifyNever(listener!.noParamReturnVoid());
      },
    );
  });

  group('isRowIdxHovered', () {
    const int givenHoveredRowIdx = 3;

    setUp(() {
      stateManager.setHoveredRowIdx(givenHoveredRowIdx);
    });

    test('should return true if rowIdx is equal to the given rowIdx.', () {
      expect(
        stateManager.isRowIdxHovered(givenHoveredRowIdx),
        isTrue,
      );
    });

    test('should return false if hoveredRowIdx is null.', () {
      stateManager.setHoveredRowIdx(null);

      expect(
        stateManager.isRowIdxHovered(givenHoveredRowIdx),
        isFalse,
      );
    });
  });
}
