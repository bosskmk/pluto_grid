import 'dart:math';

import 'package:example/screen/feature/column_sorting_screen.dart';
import 'package:example/screen/feature/number_type_column_screen.dart';
import 'package:example/screen/feature/text_type_column_screen.dart';
import 'package:example/widget/pluto_grid_title.dart';
import 'package:example/widget/pluto_section.dart';
import 'package:flutter/material.dart';

import '../widget/pluto_list_tile.dart';
import 'feature/cell_selection_screen.dart';
import 'feature/column_moving_screen.dart';
import 'feature/column_resizing_screen.dart';
import 'feature/copy_and_paste_screen.dart';
import 'feature/dark_mode_screen.dart';
import 'feature/date_type_column_screen.dart';
import 'feature/dual_mode_screen.dart';
import 'feature/moving_screen.dart';
import 'feature/row_selection_screen.dart';
import 'feature/selection_type_column_screen.dart';
import 'feature/time_type_column_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (ctx, size) {
          return Stack(
            children: [
              Positioned.fill(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF2E4370),
                        Color(0xFF33C1E8),
                      ],
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            30,
                            100,
                            30,
                            0,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: PlutoGridTitle(
                              fontSize: max(size.maxWidth / 20, 38),
                            ),
                          ),
                        ),
                        PlutoSection(
                          title: 'Features',
                          child: PlutoFeatures(),
                          // color: Colors.white,
                          fontColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PlutoFeatures extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          PlutoListTile(
            title: 'Column moving',
            description:
                'Dragging the column heading left or right moves the column left and right.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, ColumnMovingScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Column resizing',
            description:
                'Dragging the icon to the right of the column title left or right changes the width of the column.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, ColumnResizingScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Column sorting',
            description:
                'Ascending or Descending by clicking on the column heading.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, ColumnSortingScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Text type column',
            description: 'A column to enter a character value.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, TextTypeColumnScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Number type column',
            description: 'A column to enter a number value.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, NumberTypeColumnScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Date type column',
            description: 'A column to enter a date value.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, DateTypeColumnScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Time type column',
            description: 'A column to enter a time value.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, TimeTypeColumnScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Selection type column',
            description: 'A column to enter a selection value.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, SelectionTypeColumnScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Row selection',
            description:
                'In Row selection mode, Shift + tap or long tap and then move or Control + tap to select a row.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, RowSelectionScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Cell selection',
            description:
                'In Square selection mode, Shift + tap or long tap and then move to select cells.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, CellSelectionScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Copy and Paste',
            description:
                'Copy and paste are operated depending on the cell and row selection status.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, CopyAndPasteScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Moving',
            description:
                'Change the current cell position with the arrow keys, enter key, and tab key.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, MovingScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Dual mode',
            description:
                'Place the grid on the left and right and move or edit with the keyboard.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, DualModeScreen.routeName);
            },
          ),
          PlutoListTile.dark(
            title: 'Dark mode',
            description: 'Change the entire theme of the grid to Dark.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, DarkModeScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
