import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'constants/pluto_colors.dart';
import 'screen/feature/add_and_remove_rows_screen.dart';
import 'screen/feature/cell_selection_screen.dart';
import 'screen/feature/column_fixing_screen.dart';
import 'screen/feature/column_moving_screen.dart';
import 'screen/feature/column_resizing_screen.dart';
import 'screen/feature/column_sorting_screen.dart';
import 'screen/feature/copy_and_paste_screen.dart';
import 'screen/feature/dark_mode_screen.dart';
import 'screen/feature/date_type_column_screen.dart';
import 'screen/feature/dual_mode_screen.dart';
import 'screen/feature/grid_as_popup_screen.dart';
import 'screen/feature/listing_mode_screen.dart';
import 'screen/feature/moving_screen.dart';
import 'screen/feature/number_type_column_screen.dart';
import 'screen/feature/row_selection_screen.dart';
import 'screen/feature/selection_type_column_screen.dart';
import 'screen/feature/text_type_column_screen.dart';
import 'screen/feature/time_type_column_screen.dart';
import 'screen/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: kReleaseMode ? HomeScreen.routeName : HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(),
        ColumnMovingScreen.routeName: (context) => ColumnMovingScreen(),
        ColumnFixingScreen.routeName: (context) => ColumnFixingScreen(),
        ColumnResizingScreen.routeName: (context) => ColumnResizingScreen(),
        ColumnSortingScreen.routeName: (context) => ColumnSortingScreen(),
        TextTypeColumnScreen.routeName: (context) => TextTypeColumnScreen(),
        NumberTypeColumnScreen.routeName: (context) => NumberTypeColumnScreen(),
        DateTypeColumnScreen.routeName: (context) => DateTypeColumnScreen(),
        TimeTypeColumnScreen.routeName: (context) => TimeTypeColumnScreen(),
        SelectionTypeColumnScreen.routeName: (context) =>
            SelectionTypeColumnScreen(),
        RowSelectionScreen.routeName: (context) => RowSelectionScreen(),
        CellSelectionScreen.routeName: (context) => CellSelectionScreen(),
        CopyAndPasteScreen.routeName: (context) => CopyAndPasteScreen(),
        MovingScreen.routeName: (context) => MovingScreen(),
        AddAndRemoveRowsScreen.routeName: (context) => AddAndRemoveRowsScreen(),
        DualModeScreen.routeName: (context) => DualModeScreen(),
        GridAsPopupScreen.routeName: (context) => GridAsPopupScreen(),
        ListingModeScreen.routeName: (context) => ListingModeScreen(),
        DarkModeScreen.routeName: (context) => DarkModeScreen(),
      },
      theme: ThemeData(
        primaryColor: PlutoColors.primaryColor,
        fontFamily: 'OpenSans',
        backgroundColor: PlutoColors.backgroundColor,
        scaffoldBackgroundColor: PlutoColors.backgroundColor,
      ),
    );
  }
}
