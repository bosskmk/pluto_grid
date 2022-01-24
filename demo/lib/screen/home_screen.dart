import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../helper/launch_url.dart';
import '../widget/pluto_contributor_tile.dart';
import '../widget/pluto_grid_title.dart';
import '../widget/pluto_list_tile.dart';
import '../widget/pluto_section.dart';
import '../widget/pluto_text_color_animation.dart';
import 'feature/add_and_remove_column_row_screen.dart';
import 'feature/cell_renderer_screen.dart';
import 'feature/cell_selection_screen.dart';
import 'feature/column_filtering_screen.dart';
import 'feature/column_freezing_screen.dart';
import 'feature/column_group_screen.dart';
import 'feature/column_hiding_screen.dart';
import 'feature/column_moving_screen.dart';
import 'feature/column_resizing_screen.dart';
import 'feature/column_sorting_screen.dart';
import 'feature/copy_and_paste_screen.dart';
import 'feature/dark_mode_screen.dart';
import 'feature/date_type_column_screen.dart';
import 'feature/dual_mode_screen.dart';
import 'feature/editing_state_screen.dart';
import 'feature/grid_as_popup_screen.dart';
import 'feature/listing_mode_screen.dart';
import 'feature/moving_screen.dart';
import 'feature/number_type_column_screen.dart';
import 'feature/row_color_screen.dart';
import 'feature/row_moving_screen.dart';
import 'feature/row_pagination_screen.dart';
import 'feature/row_selection_screen.dart';
import 'feature/row_with_checkbox_screen.dart';
import 'feature/selection_type_column_screen.dart';
import 'feature/text_type_column_screen.dart';
import 'feature/time_type_column_screen.dart';
import 'feature/value_formatter_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/';

  const HomeScreen({Key? key}) : super(key: key);

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
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                          ),
                          child: const PlutoTextColorAnimation(
                            text: 'The DataGrid for Flutter.',
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Center(
                          child: Column(
                            children: [
                              IconButton(
                                icon: const FaIcon(FontAwesomeIcons.link),
                                color: Colors.white,
                                onPressed: () {
                                  launchUrl(
                                      'https://pub.dev/packages/pluto_grid');
                                },
                              ),
                              const Text(
                                'pub.dev',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const PlutoSection(
                          title: 'Features',
                          fontColor: Colors.white,
                          child: PlutoFeatures(),
                          // color: Colors.white,
                        ),
                        const PlutoSection(
                          title: 'Contributors',
                          fontColor: Colors.white,
                          child: PlutoContributors(),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Center(
                          child: Column(
                            children: [
                              IconButton(
                                icon: const FaIcon(FontAwesomeIcons.github),
                                color: Colors.white,
                                onPressed: () {
                                  launchUrl(
                                      'https://github.com/bosskmk/pluto_grid');
                                },
                              ),
                              const Text(
                                'Github',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        Center(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                launchUrl('https://www.buymeacoffee.com/manki');
                              },
                              child: Image.asset(
                                'assets/images/buy_me_a_coffee.png',
                                height: 60,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 100,
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
  final Icon newIcon = const Icon(
    Icons.fiber_new,
    color: Colors.deepOrange,
  );

  final Icon updateIcon = const Icon(
    Icons.update,
    color: Colors.deepOrange,
  );

  const PlutoFeatures({Key? key}) : super(key: key);

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
            title: 'Column freezing',
            description: 'Freeze the column to the left or right.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, ColumnFreezingScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Column group',
            description: 'Group columns by the desired depth.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, ColumnGroupScreen.routeName);
            },
            trailing: newIcon,
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
            title: 'Column filtering',
            description: 'Filter rows by setting filters on columns.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, ColumnFilteringScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Column hiding',
            description: 'Hide or un-hide the column.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, ColumnHidingScreen.routeName);
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
            title: 'Value formatter',
            description: 'Formatter for display of cell values.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, ValueFormatterScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Row color',
            description: 'Dynamically change the background color of row.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, RowColorScreen.routeName);
            },
            trailing: newIcon,
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
            title: 'Row moving',
            description: 'You can move the row by dragging it.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, RowMovingScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Row pagination',
            description: 'You can paginate the rows.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, RowPaginationScreen.routeName);
            },
            trailing: newIcon,
          ),
          PlutoListTile(
            title: 'Row with checkbox',
            description: 'You can select rows with checkbox.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, RowWithCheckboxScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Cell selection',
            description:
                'In cell selection mode, Shift + tap or long tap and then move to select cells.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, CellSelectionScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Cell renderer',
            description:
                'You can change the widget of the cell through the renderer.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, CellRendererScreen.routeName);
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
            title: 'Editing state',
            description: 'Controls the editing state of a cell.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, EditingStateScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Add and Remove Columns, Rows',
            description: 'You can add or delete columns, rows.',
            onTapLiveDemo: () {
              Navigator.pushNamed(
                  context, AddAndRemoveColumnRowScreen.routeName);
            },
            trailing: updateIcon,
          ),
          PlutoListTile(
            title: 'Dual mode',
            description:
                'Place the grid on the left and right and move or edit with the keyboard.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, DualModeScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Grid as Popup',
            description:
                'You can call the grid by popping up with the TextField.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, GridAsPopupScreen.routeName);
            },
          ),
          PlutoListTile(
            title: 'Listing mode',
            description: 'Listing mode to open or navigate to the Detail page.',
            onTapLiveDemo: () {
              Navigator.pushNamed(context, ListingModeScreen.routeName);
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

class PlutoContributors extends StatelessWidget {
  const PlutoContributors({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          PlutoContributorTile(
            name: 'Manki Kim',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/bosskmk');
            },
          ),
          PlutoContributorTile(
            name: 'Alexey Volkov',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/ASGAlex');
            },
          ),
          PlutoContributorTile(
            name: 'MrCasCode',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/MrCasCode');
            },
          ),
          PlutoContributorTile(
            name: 'Wang Chuanbin',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/Chuanbin-Wang');
            },
          ),
          PlutoContributorTile(
            name: 'sheentim',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/sheentim');
            },
          ),
          PlutoContributorTile(
            name: 'Christian Arduino',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/christianarduino');
            },
          ),
          PlutoContributorTile(
            name: 'Enrique Cardona',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/henry2man');
            },
          ),
          PlutoContributorTile.invisible(
            name: 'And you.',
            linkTitle: 'Github',
            onTapLink: () {
              launchUrl('https://github.com/bosskmk/pluto_grid');
            },
          ),
        ],
      ),
    );
  }
}
