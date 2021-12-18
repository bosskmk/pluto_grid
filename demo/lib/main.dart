import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'constants/pluto_grid_example_colors.dart';
import 'screen/development_screen.dart';
import 'screen/empty_screen.dart';
import 'screen/feature/add_and_remove_rows_screen.dart';
import 'screen/feature/cell_renderer_screen.dart';
import 'screen/feature/cell_selection_screen.dart';
import 'screen/feature/column_filtering_screen.dart';
import 'screen/feature/column_freezing_screen.dart';
import 'screen/feature/column_group_screen.dart';
import 'screen/feature/column_hiding_screen.dart';
import 'screen/feature/column_moving_screen.dart';
import 'screen/feature/column_resizing_screen.dart';
import 'screen/feature/column_sorting_screen.dart';
import 'screen/feature/copy_and_paste_screen.dart';
import 'screen/feature/dark_mode_screen.dart';
import 'screen/feature/date_type_column_screen.dart';
import 'screen/feature/dual_mode_screen.dart';
import 'screen/feature/editing_state_screen.dart';
import 'screen/feature/grid_as_popup_screen.dart';
import 'screen/feature/listing_mode_screen.dart';
import 'screen/feature/moving_screen.dart';
import 'screen/feature/number_type_column_screen.dart';
import 'screen/feature/row_color_screen.dart';
import 'screen/feature/row_moving_screen.dart';
import 'screen/feature/row_pagination_screen.dart';
import 'screen/feature/row_selection_screen.dart';
import 'screen/feature/row_with_checkbox_screen.dart';
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
        EditingStateScreen.routeName: (context) => const EditingStateScreen(),
        ColumnMovingScreen.routeName: (context) => const ColumnMovingScreen(),
        ColumnFreezingScreen.routeName: (context) =>
            const ColumnFreezingScreen(),
        ColumnGroupScreen.routeName: (context) => const ColumnGroupScreen(),
        ColumnResizingScreen.routeName: (context) =>
            const ColumnResizingScreen(),
        ColumnSortingScreen.routeName: (context) => const ColumnSortingScreen(),
        ColumnFilteringScreen.routeName: (context) =>
            const ColumnFilteringScreen(),
        ColumnHidingScreen.routeName: (context) => const ColumnHidingScreen(),
        TextTypeColumnScreen.routeName: (context) =>
            const TextTypeColumnScreen(),
        RowColorScreen.routeName: (context) => const RowColorScreen(),
        NumberTypeColumnScreen.routeName: (context) =>
            const NumberTypeColumnScreen(),
        DateTypeColumnScreen.routeName: (context) =>
            const DateTypeColumnScreen(),
        TimeTypeColumnScreen.routeName: (context) =>
            const TimeTypeColumnScreen(),
        SelectionTypeColumnScreen.routeName: (context) =>
            const SelectionTypeColumnScreen(),
        ValueFormatterScreen.routeName: (context) =>
            const ValueFormatterScreen(),
        RowSelectionScreen.routeName: (context) => const RowSelectionScreen(),
        RowMovingScreen.routeName: (context) => const RowMovingScreen(),
        RowPaginationScreen.routeName: (context) => const RowPaginationScreen(),
        RowWithCheckboxScreen.routeName: (context) =>
            const RowWithCheckboxScreen(),
        CellSelectionScreen.routeName: (context) => const CellSelectionScreen(),
        CellRendererScreen.routeName: (context) => const CellRendererScreen(),
        CopyAndPasteScreen.routeName: (context) => const CopyAndPasteScreen(),
        MovingScreen.routeName: (context) => const MovingScreen(),
        AddAndRemoveRowsScreen.routeName: (context) =>
            const AddAndRemoveRowsScreen(),
        DualModeScreen.routeName: (context) => const DualModeScreen(),
        GridAsPopupScreen.routeName: (context) => const GridAsPopupScreen(),
        ListingModeScreen.routeName: (context) => const ListingModeScreen(),
        DarkModeScreen.routeName: (context) => const DarkModeScreen(),
        // only development
        EmptyScreen.routeName: (context) => const EmptyScreen(),
        DevelopmentScreen.routeName: (context) => const DevelopmentScreen(),
      },
      theme: ThemeData(
        primaryColor: PlutoGridExampleColors.primaryColor,
        fontFamily: 'OpenSans',
        backgroundColor: PlutoGridExampleColors.backgroundColor,
        scaffoldBackgroundColor: PlutoGridExampleColors.backgroundColor,
      ),
    );
  }
}
