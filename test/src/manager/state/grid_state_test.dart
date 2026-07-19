import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../helper/column_helper.dart';
import '../../../helper/row_helper.dart';
import '../../../mock/mock_methods.dart';
import '../../../mock/shared_mocks.mocks.dart';

void main() {
  PlutoGridStateManager createStateManager({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
    FocusNode? gridFocusNode,
    PlutoGridScrollController? scroll,
    PlutoGridConfiguration configuration = const PlutoGridConfiguration(),
  }) {
    final stateManager = PlutoGridStateManager(
      columns: columns,
      rows: rows,
      gridFocusNode: gridFocusNode ?? MockFocusNode(),
      scroll: scroll ?? MockPlutoGridScrollController(),
      configuration: configuration,
    );

    stateManager.setEventManager(MockPlutoGridEventManager());

    return stateManager;
  }

  group('setConfiguration', () {
    testWidgets(
      'When the configuration is changed, listeners should be notified.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = ColumnHelper.textColumn('body', count: 3);
        List<PlutoRow> rows = RowHelper.count(3, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
        );

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        stateManager.setConfiguration(
          const PlutoGridConfiguration(
            style: PlutoGridStyleConfig(enableGridBorderShadow: true),
          ),
        );

        // then
        verify(listener.noParamReturnVoid()).called(1);
      },
    );

    testWidgets(
      'When the configuration is set to an equal value, '
      'listeners should not be notified.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = ColumnHelper.textColumn('body', count: 3);
        List<PlutoRow> rows = RowHelper.count(3, columns);

        const configuration = PlutoGridConfiguration();

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
          configuration: configuration,
        );

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        stateManager.setConfiguration(configuration);

        // then
        verifyNever(listener.noParamReturnVoid());
      },
    );

    testWidgets(
      'When notify is false, listeners should not be notified '
      'even though the configuration changed.',
      (WidgetTester tester) async {
        // given
        List<PlutoColumn> columns = ColumnHelper.textColumn('body', count: 3);
        List<PlutoRow> rows = RowHelper.count(3, columns);

        PlutoGridStateManager stateManager = createStateManager(
          columns: columns,
          rows: rows,
        );

        final listener = MockMethods();

        stateManager.addListener(listener.noParamReturnVoid);

        // when
        stateManager.setConfiguration(
          const PlutoGridConfiguration(
            style: PlutoGridStyleConfig(enableGridBorderShadow: true),
          ),
          notify: false,
        );

        // then
        verifyNever(listener.noParamReturnVoid());
      },
    );
  });
}
