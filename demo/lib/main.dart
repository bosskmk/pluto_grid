import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'constants/pluto_grid_example_colors.dart';
import 'screen/development_screen.dart';
import 'screen/empty_screen.dart';
import 'screen/feature/add_and_remove_column_row_screen.dart';
import 'screen/feature/add_rows_asynchronously.dart';
import 'screen/feature/cell_renderer_screen.dart';
import 'screen/feature/cell_selection_screen.dart';
import 'screen/feature/column_filtering_screen.dart';
import 'screen/feature/column_footer_screen.dart';
import 'screen/feature/column_freezing_screen.dart';
import 'screen/feature/column_group_screen.dart';
import 'screen/feature/column_hiding_screen.dart';
import 'screen/feature/column_menu_screen.dart';
import 'screen/feature/column_moving_screen.dart';
import 'screen/feature/column_resizing_screen.dart';
import 'screen/feature/column_sorting_screen.dart';
import 'screen/feature/copy_and_paste_screen.dart';
import 'screen/feature/currency_type_column_screen.dart';
import 'screen/feature/dark_mode_screen.dart';
import 'screen/feature/date_type_column_screen.dart';
import 'screen/feature/dual_mode_screen.dart';
import 'screen/feature/editing_state_screen.dart';
import 'screen/feature/export_screen.dart';
import 'screen/feature/grid_as_popup_screen.dart';
import 'screen/feature/listing_mode_screen.dart';
import 'screen/feature/moving_screen.dart';
import 'screen/feature/number_type_column_screen.dart';
import 'screen/feature/row_color_screen.dart';
import 'screen/feature/row_group_screen.dart';
import 'screen/feature/row_infinity_scroll_screen.dart';
import 'screen/feature/row_lazy_pagination_screen.dart';
import 'screen/feature/row_moving_screen.dart';
import 'screen/feature/row_pagination_screen.dart';
import 'screen/feature/row_selection_screen.dart';
import 'screen/feature/row_with_checkbox_screen.dart';
import 'screen/feature/rtl_screen.dart';
import 'screen/feature/selection_type_column_screen.dart';
import 'screen/feature/text_type_column_screen.dart';
import 'screen/feature/time_type_column_screen.dart';
import 'screen/feature/value_formatter_screen.dart';
import 'screen/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute:
          kReleaseMode ? HomeScreen.routeName : DevelopmentScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => const HomeScreen(),
        AddAndRemoveColumnRowScreen.routeName: (context) =>
            const AddAndRemoveColumnRowScreen(),
        AddRowsAsynchronouslyScreen.routeName: (context) =>
            const AddRowsAsynchronouslyScreen(),
        CellRendererScreen.routeName: (context) => const CellRendererScreen(),
        CellSelectionScreen.routeName: (context) => const CellSelectionScreen(),
        RTLScreen.routeName: (context) => const RTLScreen(),
        ColumnFilteringScreen.routeName: (context) =>
            const ColumnFilteringScreen(),
        ColumnFooterScreen.routeName: (context) => const ColumnFooterScreen(),
        ColumnFreezingScreen.routeName: (context) =>
            const ColumnFreezingScreen(),
        ColumnGroupScreen.routeName: (context) => const ColumnGroupScreen(),
        ColumnHidingScreen.routeName: (context) => const ColumnHidingScreen(),
        ColumnMenuScreen.routeName: (context) => const ColumnMenuScreen(),
        ColumnMovingScreen.routeName: (context) => const ColumnMovingScreen(),
        ColumnResizingScreen.routeName: (context) =>
            const ColumnResizingScreen(),
        ColumnSortingScreen.routeName: (context) => const ColumnSortingScreen(),
        CopyAndPasteScreen.routeName: (context) => const CopyAndPasteScreen(),
        CurrencyTypeColumnScreen.routeName: (context) =>
            const CurrencyTypeColumnScreen(),
        DarkModeScreen.routeName: (context) => const DarkModeScreen(),
        DateTypeColumnScreen.routeName: (context) =>
            const DateTypeColumnScreen(),
        DualModeScreen.routeName: (context) => const DualModeScreen(),
        EditingStateScreen.routeName: (context) => const EditingStateScreen(),
        ExportScreen.routeName: (context) => const ExportScreen(),
        GridAsPopupScreen.routeName: (context) => const GridAsPopupScreen(),
        ListingModeScreen.routeName: (context) => const ListingModeScreen(),
        MovingScreen.routeName: (context) => const MovingScreen(),
        NumberTypeColumnScreen.routeName: (context) =>
            const NumberTypeColumnScreen(),
        RowColorScreen.routeName: (context) => const RowColorScreen(),
        RowGroupScreen.routeName: (context) => const RowGroupScreen(),
        RowInfinityScrollScreen.routeName: (context) =>
            const RowInfinityScrollScreen(),
        RowLazyPaginationScreen.routeName: (context) =>
            const RowLazyPaginationScreen(),
        RowMovingScreen.routeName: (context) => const RowMovingScreen(),
        RowPaginationScreen.routeName: (context) => const RowPaginationScreen(),
        RowSelectionScreen.routeName: (context) => const RowSelectionScreen(),
        RowWithCheckboxScreen.routeName: (context) =>
            const RowWithCheckboxScreen(),
        SelectionTypeColumnScreen.routeName: (context) =>
            const SelectionTypeColumnScreen(),
        TextTypeColumnScreen.routeName: (context) =>
            const TextTypeColumnScreen(),
        TimeTypeColumnScreen.routeName: (context) =>
            const TimeTypeColumnScreen(),
        ValueFormatterScreen.routeName: (context) =>
            const ValueFormatterScreen(),
        // only development
        EmptyScreen.routeName: (context) => const EmptyScreen(),
        DevelopmentScreen.routeName: (context) => const DevelopmentScreen(),
      },
      theme: ThemeData(
        primaryColor: PlutoGridExampleColors.primaryColor,
        fontFamily: 'OpenSans',
        scaffoldBackgroundColor: PlutoGridExampleColors.backgroundColor,
        colorScheme: const ColorScheme.light(
          primary: PlutoGridExampleColors.primaryColor,
          background: PlutoGridExampleColors.backgroundColor,
        ),
      ),
    );
  }
}
