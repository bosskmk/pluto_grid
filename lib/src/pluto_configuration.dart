part of '../pluto_grid.dart';

class PlutoConfiguration {
  /// border between columns.
  final bool enableColumnBorder;

  final Color gridBackgroundColor;

  /// Grid border color. (Grid outline color, Fixed column division line color)
  final Color gridBorderColor;

  /// Activated Color. (Current or Selected row, cell)
  final Color activatedColor;

  /// Activated Border Color. (Current cell)
  final Color activatedBorderColor;

  /// Row border color. (horizontal row border, vertical column border)
  final Color borderColor;

  /// Cell color in edit state. (only current cell)
  final Color cellColorInEditState;

  /// Cell color in read-only state
  final Color cellColorInReadOnlyState;

  /// Header - text style
  final TextStyle headerTextStyle;

  /// Cell - text style
  final TextStyle cellTextStyle;

  PlutoConfiguration({
    this.enableColumnBorder = false,
    this.gridBackgroundColor = Colors.white,
    this.gridBorderColor = const Color.fromRGBO(161, 165, 174, 100),
    this.activatedColor = const Color.fromRGBO(220, 245, 255, 100),
    this.activatedBorderColor = Colors.lightBlue,
    this.borderColor = const Color.fromRGBO(221, 226, 235, 100),
    this.cellColorInEditState = Colors.white,
    this.cellColorInReadOnlyState = const Color.fromRGBO(196, 199, 204, 100),
    this.headerTextStyle = const TextStyle(
      color: Colors.black,
      decoration: TextDecoration.none,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    this.cellTextStyle = const TextStyle(
      fontSize: 14,
    ),
  });
}
