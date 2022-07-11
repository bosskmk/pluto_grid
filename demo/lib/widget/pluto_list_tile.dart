import 'package:flutter/material.dart';

import '../constants/pluto_grid_example_colors.dart';

class PlutoListTile extends StatelessWidget {
  final String title;

  final String? description;

  final Function()? onTapPreview;

  final Function()? onTapLiveDemo;

  final Widget? trailing;

  const PlutoListTile({
    Key? key,
    required this.title,
    this.description,
    this.onTapPreview,
    this.onTapLiveDemo,
    this.trailing,
  })  : _color = Colors.white,
        _fontColor = PlutoGridExampleColors.fontColor,
        super(key: key);

  const PlutoListTile.dark({
    Key? key,
    required this.title,
    this.description,
    this.onTapPreview,
    this.onTapLiveDemo,
    this.trailing,
  })  : _color = Colors.black87,
        _fontColor = Colors.white70,
        super(key: key);

  const PlutoListTile.amber({
    Key? key,
    required this.title,
    this.description,
    this.onTapPreview,
    this.onTapLiveDemo,
    this.trailing,
  })  : _color = Colors.amber,
        _fontColor = Colors.black87,
        super(key: key);

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
            trailing: trailing,
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
                          onPressed: onTapPreview,
                          child: const Text('Preview'),
                        ),
                      if (onTapLiveDemo != null)
                        TextButton(
                          onPressed: onTapLiveDemo,
                          child: const Text('LiveDemo'),
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
