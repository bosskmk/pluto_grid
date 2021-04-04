import 'package:flutter/material.dart';

import '../constants/pluto_grid_example_colors.dart';

class PlutoListTile extends StatelessWidget {
  final String title;

  final String? description;

  final Function()? onTapPreview;

  final Function()? onTapLiveDemo;

  PlutoListTile({
    required this.title,
    this.description,
    this.onTapPreview,
    this.onTapLiveDemo,
  })  : _color = Colors.white,
        _fontColor = PlutoGridExampleColors.fontColor;

  PlutoListTile.dark({
    required this.title,
    this.description,
    this.onTapPreview,
    this.onTapLiveDemo,
  })  : _color = Colors.black87,
        _fontColor = Colors.white70;

  final Color _color;
  final Color _fontColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 300,
        maxWidth: 300,
        minHeight: 180,
        maxHeight: 180,
      ),
      child: Card(
        color: _color,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: ListTile(
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (onTapPreview != null || onTapLiveDemo != null)
                  Wrap(
                    spacing: 10,
                    children: [
                      if (onTapPreview != null)
                        TextButton(
                          child: const Text('Preview'),
                          onPressed: onTapPreview,
                        ),
                      if (onTapLiveDemo != null)
                        TextButton(
                          child: const Text('LiveDemo'),
                          onPressed: onTapLiveDemo,
                        ),
                    ],
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    description!,
                    style: TextStyle(
                      color: _fontColor,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
            contentPadding: const EdgeInsets.all(15),
          ),
        ),
      ),
    );
  }
}
