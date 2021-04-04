import 'package:flutter/material.dart';

class PlutoGridTitle extends StatelessWidget {
  final double? fontSize;

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
          color: const Color(0xFF33BDE5),
        ),
        children: [
          TextSpan(
            text: 'Grid',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
