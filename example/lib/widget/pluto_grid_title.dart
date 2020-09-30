import 'package:example/constants/pluto_colors.dart';
import 'package:flutter/material.dart';

class PlutoGridTitle extends StatelessWidget {
  final double fontSize;

  PlutoGridTitle({
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'Pluto',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: PlutoColors.primaryColor,
        ),
        children: [
          TextSpan(
            text: 'Grid',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
