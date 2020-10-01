import 'package:example/widget/pluto_expansion_tile.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title - PlutoGrid'),
      ),
      body: Container(
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
  }
}
