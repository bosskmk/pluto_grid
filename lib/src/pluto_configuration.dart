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

  /// Column - text style
  final TextStyle columnTextStyle;

  /// Cell - text style
  final TextStyle cellTextStyle;

  /// Icon color. (column menu, cell of popup type)
  final Color iconColor;

  /// BackgroundColor of Popup menu. (column menu)
  final Color menuBackgroundColor;

  /// When you select a value in the pop-up grid, it moves down.
  final bool enableMoveDownAfterSelecting;

  /// PlutoEnterKeyAction.EditingAndMoveDown : It switches to the editing state, and moves down in the editing state.
  /// PlutoEnterKeyAction.EditingAndMoveRight : It switches to the editing state, and moves to the right in the editing state.
  /// PlutoEnterKeyAction.ToggleEditing : The editing state is toggled and cells are not moved.
  /// PlutoEnterKeyAction.None : There is no action.
  final PlutoEnterKeyAction enterKeyAction;

  PlutoConfiguration({
    this.enableColumnBorder = false,
    this.gridBackgroundColor = Colors.white,
    this.gridBorderColor = const Color(0xFFA1A5AE),
    this.activatedColor = const Color(0xFFDCF5FF),
    this.activatedBorderColor = Colors.lightBlue,
    this.borderColor = const Color(0xFFDDE2EB),
    this.cellColorInEditState = Colors.white,
    this.cellColorInReadOnlyState = const Color(0xFFC4C7CC),
    this.columnTextStyle = const TextStyle(
      color: Colors.black,
      decoration: TextDecoration.none,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    this.cellTextStyle = const TextStyle(
      color: Colors.black,
      fontSize: 14,
    ),
    this.iconColor = Colors.black26,
    this.menuBackgroundColor = Colors.white,
    this.enableMoveDownAfterSelecting = true,
    this.enterKeyAction = PlutoEnterKeyAction.EditingAndMoveDown,
  });

  PlutoConfiguration.dark({
    this.enableColumnBorder = false,
    this.gridBackgroundColor = const Color(0xFF111111),
    this.gridBorderColor = const Color(0xFF000000),
    this.activatedColor = const Color(0xFF313131),
    this.activatedBorderColor = const Color(0xFFFFFFFF),
    this.borderColor = const Color(0xFF000000),
    this.cellColorInEditState = const Color(0xFF666666),
    this.cellColorInReadOnlyState = const Color(0xFF222222),
    this.columnTextStyle = const TextStyle(
      color: Colors.white,
      decoration: TextDecoration.none,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    this.cellTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 14,
    ),
    this.iconColor = Colors.white38,
    this.menuBackgroundColor = const Color(0xFF414141),
    this.enableMoveDownAfterSelecting = true,
    this.enterKeyAction = PlutoEnterKeyAction.EditingAndMoveDown,
  });
}

enum PlutoEnterKeyAction {
  EditingAndMoveDown,
  EditingAndMoveRight,
  ToggleEditing,
  None,
}

extension PlutoEnterKeyActionExtension on PlutoEnterKeyAction {
  bool get isEditingAndMoveDown =>
      this == PlutoEnterKeyAction.EditingAndMoveDown;
  bool get isEditingAndMoveRight =>
      this == PlutoEnterKeyAction.EditingAndMoveRight;
  bool get isToggleEditing => this == PlutoEnterKeyAction.ToggleEditing;
  bool get isNone => this == null || this == PlutoEnterKeyAction.None;
}
