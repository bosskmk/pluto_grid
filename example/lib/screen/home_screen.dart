import 'dart:math';

import 'package:example/widget/pluto_section.dart';
import 'package:flutter/material.dart';

import '../widget/pluto_grid_title.dart';
import '../widget/pluto_list_tile.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (ctx, size) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Align(
                  alignment: Alignment.center,
                  child: PlutoGridTitle(
                    fontSize: max(size.maxWidth / 40, 38),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                PlutoSection(
                  title: 'Features',
                  child: PlutoFeatures(),
                  // color: Colors.white,
                  fontColor: Colors.black54,
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
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
        spacing: 15,
        runSpacing: 5,
        children: [
          PlutoListTile(
            title: 'Column moving',
            description:
                'Dragging the column heading left or right moves the column left and right.',
            tags: ['Column'],
          ),
          PlutoListTile(
            title: 'Column resizing',
            description:
                'Dragging the icon to the right of the column title left or right changes the width of the column.',
            tags: ['Column'],
          ),
          PlutoListTile(
            title: 'Column sorting',
            description:
                'Ascending or Descending by clicking on the column heading.',
            tags: ['Column'],
          ),
          PlutoListTile(
            title: 'Text type column',
            description: 'A column to enter a character value.',
            tags: ['Column'],
          ),
          PlutoListTile(
            title: 'Number type column',
            description: 'A column to enter a number value.',
            tags: ['Column'],
          ),
          PlutoListTile(
            title: 'Date type column',
            description: 'A column to enter a date value.',
            tags: ['Column'],
          ),
          PlutoListTile(
            title: 'Time type column',
            description: 'A column to enter a time value.',
            tags: ['Column'],
          ),
          PlutoListTile(
            title: 'Selection type column',
            description: 'A column to enter a selection value.',
            tags: ['Column'],
          ),
        ],
      ),
    );
  }
}
