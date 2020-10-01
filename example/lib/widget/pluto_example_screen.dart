import 'package:example/helper/launch_url.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widget/pluto_expansion_tile.dart';

class PlutoExampleScreen extends StatelessWidget {
  final String title;
  final String topTitle;
  final List<Widget> topContents;
  final List<Widget> topButtons;
  final Widget body;

  PlutoExampleScreen({
    this.title,
    this.topTitle,
    this.topContents,
    this.topButtons,
    this.body,
  });

  AlertDialog reportingDialog(BuildContext context) {
    return AlertDialog(
      title: Text('Reporting'),
      content: Container(
        width: 300,
        child: Text(
            'Have you found the problem? Or do you have any questions?\n(Selecting Yes will open the Github issue.)'),
      ),
      actions: [
        TextButton(
          child: Text(
            'No',
            style: TextStyle(
              color: Colors.deepOrange,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Yes'),
          onPressed: () {
            launchUrl('https://github.com/bosskmk/pluto_grid/issues');
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title - PlutoGrid'),
      ),
      body: LayoutBuilder(
        builder: (ctx, size) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              width: size.maxWidth,
              height: size.maxHeight,
              constraints: BoxConstraints(
                minHeight: 600,
              ),
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  PlutoExpansionTile(
                    title: topTitle,
                    children: topContents,
                    buttons: topButtons,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: body,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return reportingDialog(context);
            },
          );
        },
        child: FaIcon(
          FontAwesomeIcons.exclamation,
          color: Colors.white,
        ),
        backgroundColor: Color(0xFF33BDE5),
      ),
    );
  }
}
