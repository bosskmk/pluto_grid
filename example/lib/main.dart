import 'package:example/constants/pluto_colors.dart';
import 'package:example/screen/feature/cell_selection_screen.dart';
import 'package:example/screen/feature/column_moving_screen.dart';
import 'package:example/screen/feature/column_resizing_screen.dart';
import 'package:example/screen/feature/column_sorting_screen.dart';
import 'package:example/screen/feature/copy_and_paste_screen.dart';
import 'package:example/screen/feature/dark_mode_screen.dart';
import 'package:example/screen/feature/date_type_column_screen.dart';
import 'package:example/screen/feature/dual_mode_screen.dart';
import 'package:example/screen/feature/moving_screen.dart';
import 'package:example/screen/feature/number_type_column_screen.dart';
import 'package:example/screen/feature/row_selection_screen.dart';
import 'package:example/screen/feature/selection_type_column_screen.dart';
import 'package:example/screen/feature/text_type_column_screen.dart';
import 'package:example/screen/feature/time_type_column_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
        DualModeScreen.routeName: (context) => DualModeScreen(),
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
