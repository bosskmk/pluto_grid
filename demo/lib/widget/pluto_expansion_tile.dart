import 'package:flutter/material.dart';

class PlutoExpansionTile extends StatelessWidget {
  final String title;

  final List<Widget>? children;

  final List<Widget>? buttons;

  PlutoExpansionTile({
    super.key,
    required this.title,
    this.children,
    this.buttons,
  }) : assert(title.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        border: Border.all(
          color: const Color(0xFFA1A5AE),
        ),
      ),
      child: ExpansionTile(
        title: Text(title),
        initiallyExpanded: true,
        childrenPadding: const EdgeInsets.all(20),
        expandedAlignment: Alignment.topLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (children != null) ...children!,
          if (buttons != null)
            Container(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Wrap(
                children: buttons!,
              ),
            ),
        ],
      ),
    );
  }
}
