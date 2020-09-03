import 'dart:math';

import 'package:example/screen/dual_grid_screen.dart';
import 'package:example/screen/normal_grid_screen.dart';
import 'package:example/widget/contributor.dart';
import 'package:example/widget/link.dart';
import 'package:flutter/material.dart';

import '../widget/feature.dart';
import '../widget/image_slider.dart';
import '../widget/main_drawer.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PlutoGrid'),
      ),
      drawer: MainDrawer(),
      body: LayoutBuilder(
        builder: (ctx, size) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                ),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Pluto',
                          style: TextStyle(
                            fontSize: max(size.maxWidth / 18, 24),
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          children: [
                            TextSpan(
                              text: 'Grid',
                              style: TextStyle(
                                fontSize: max(size.maxWidth / 18, 24),
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.cyan,
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                        ),
                        child: Text(
                          'Alpha',
                          style: TextStyle(
                            fontSize: max(size.maxWidth / 60, 12),
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 21),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'The DataGrid for flutter.',
                    style: TextStyle(
                      fontSize: max(size.maxWidth / 38, 22),
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                SizedBox(
                  width: size.maxWidth,
                  height: 550,
                  child: ImageSlider(size),
                ),
                SizedBox(
                  height: 80,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'PlutoGrid features.',
                    style: TextStyle(
                      fontSize: max(size.maxWidth / 38, 22),
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Wrap(
                  alignment: WrapAlignment.start,
                  direction: Axis.horizontal,
                  children: [
                    Feature(
                        'Column functions',
                        'Columns can be aligned, moved, and fixed left and right. '
                            'You can also adjust the width manually or automatically. '
                            'Drag the column heading or drag the icon to the right of the column.'),
                    Feature(
                        'Cell types',
                        'There are text, number, select, date, and time cell types. '
                            'Enter or tap on the cell. '
                            'You can also cancel the text you are writing with the ESC key.'),
                    Feature(
                        'Dual Grid',
                        'You can edit the grid while moving left and right at the same time. '
                            'You can move the grid by tapping the grid or using Control + Left or Right arrow keys. '
                            'Among the two grids, the currently focused grid shows the background color of the row.'),
                    Feature('All Flutter platforms supported',
                        'The goal is to run on Android, iOS, Web, Windows, and Macos platforms supported by Flutter.'),
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'Play Demo.',
                          style: TextStyle(
                            fontSize: max(size.maxWidth / 38, 22),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        direction: Axis.horizontal,
                        spacing: 30,
                        children: [
                          RaisedButton(
                            color: Colors.white,
                            onPressed: () => Navigator.pushNamed(
                                context, NormalGridScreen.routeName),
                            child: Text(
                              'Normal Grid',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                          ),
                          RaisedButton(
                            color: Colors.white,
                            onPressed: () => Navigator.pushNamed(
                                context, DualGridScreen.routeName),
                            child: Text(
                              'Dual Grid',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 80,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'Links.',
                    style: TextStyle(
                      fontSize: max(size.maxWidth / 38, 22),
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Wrap(
                  alignment: WrapAlignment.start,
                  direction: Axis.horizontal,
                  children: [
                    Link(
                      title: 'Github',
                      description:
                          'This project is open source on github and licensed by MIT.',
                      url: 'https://github.com/bosskmk/pluto_grid',
                    ),
                    Link(
                      title: 'pub.dev',
                      description: 'Dart official package repository.',
                      url: 'https://pub.dev/packages/pluto_grid',
                    ),
                  ],
                ),
                SizedBox(
                  height: 80,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    'Contributors.',
                    style: TextStyle(
                      fontSize: max(size.maxWidth / 38, 22),
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  direction: Axis.horizontal,
                  children: [
                    Contributor(
                      profile: 'assets/images/contributor_bosskmk.jpg',
                      name: 'ManKi Kim',
                      description: 'I\'ve been doing backend web development.',
                      homepage: 'https://github.com/bosskmk',
                    ),
                  ],
                ),
                SizedBox(
                  height: 80,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
