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

  /// Checked Color. (Checked rows)
  final Color checkedColor;

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

  final PlutoGridLocaleText localeText;

  /// Customise scrollbars for desktop usage
  final PlutoScrollbarConfig scrollbarConfig;

  PlutoConfiguration({
    this.enableColumnBorder = false,
    this.gridBackgroundColor = Colors.white,
    this.gridBorderColor = const Color(0xFFA1A5AE),
    this.activatedColor = const Color(0xFFDCF5FF),
    this.activatedBorderColor = Colors.lightBlue,
    this.checkedColor = const Color(0x11757575),
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
    this.localeText = const PlutoGridLocaleText(),
    this.scrollbarConfig = const PlutoScrollbarConfig.noScroll()
  });

  PlutoConfiguration.dark({
    this.enableColumnBorder = false,
    this.gridBackgroundColor = const Color(0xFF111111),
    this.gridBorderColor = const Color(0xFF000000),
    this.activatedColor = const Color(0xFF313131),
    this.activatedBorderColor = const Color(0xFFFFFFFF),
    this.checkedColor = const Color(0x11202020),
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
    this.localeText = const PlutoGridLocaleText(),
    this.scrollbarConfig = const PlutoScrollbarConfig.noScroll()
  });
}

class PlutoGridLocaleText {
  // Column menu
  final String unfixColumn;
  final String toLeftColumn;
  final String toRightColumn;
  final String autoSizeColumn;
  // Date column popup
  final String sunday;
  final String monday;
  final String tuesday;
  final String wednesday;
  final String thursday;
  final String friday;
  final String saturday;
  // Time column popup
  final String hour;
  final String minute;

  const PlutoGridLocaleText({
    // Column menu
    this.unfixColumn = 'Unfix',
    this.toLeftColumn = 'ToLeft',
    this.toRightColumn = 'ToRight',
    this.autoSizeColumn = 'AutoSize',
    // Date popup
    this.sunday = 'Su',
    this.monday = 'Mo',
    this.tuesday = 'Tu',
    this.wednesday = 'We',
    this.thursday = 'Th',
    this.friday = 'Fr',
    this.saturday = 'Sa',
    // Time column popup
    this.hour = 'Hour',
    this.minute = 'Minute',
  });

  const PlutoGridLocaleText.korean({
    // Column menu
    this.unfixColumn = '고정 해제',
    this.toLeftColumn = '왼쪽 고정',
    this.toRightColumn = '오른쪽 고정',
    this.autoSizeColumn = '넓이 자동 조정',
    // Date popup
    this.sunday = '일',
    this.monday = '월',
    this.tuesday = '화',
    this.wednesday = '수',
    this.thursday = '목',
    this.friday = '금',
    this.saturday = '토',
    // Time column popup
    this.hour = '시',
    this.minute = '분',
  });

  const PlutoGridLocaleText.russian({
    // Column menu
    this.unfixColumn = 'Открепить',
    this.toLeftColumn = 'Закрепить слева',
    this.toRightColumn = 'Закрепить справа',
    this.autoSizeColumn = 'Автоматический размер',
    // Date popup
    this.sunday = 'Вск',
    this.monday = 'Пн',
    this.tuesday = 'Вт',
    this.wednesday = 'Ср',
    this.thursday = 'Чт',
    this.friday = 'Пт',
    this.saturday = 'Сб',
    // Time column popup
    this.hour = 'Часы',
    this.minute = 'Минуты',
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

/// Allows to customise scrollbars "look and feel"
/// The general feature is making vertical scrollbar draggable and therefore more useful
/// for desktop systems. Set [draggableScrollbar] to true to achieve this behavior. Also
/// changing [isAlwaysShown] to true is recommended for more usability at desktops
///
/// Unfortunately, horizontal scrollbar still will not be draggable, it seems like
/// framework limitation
class PlutoScrollbarConfig {
  PlutoScrollbarConfig({
    this.draggableScrollbar = false,
    this.isAlwaysShown = false,
    Radius scrollbarRadius,
    Radius scrollbarRadiusWhileDragging,
    double scrollbarThickness,
    double scrollbarThicknessWhileDragging})
      : this.scrollbarThickness = scrollbarThickness ??
      (draggableScrollbar ? (CupertinoScrollbar.defaultThickness) : 6.0),
        this.scrollbarRadius = scrollbarRadius ??
            (draggableScrollbar ? (CupertinoScrollbar.defaultRadius) : null),
        this.scrollbarThicknessWhileDragging = scrollbarThicknessWhileDragging ??
            CupertinoScrollbar.defaultThicknessWhileDragging,
        this.scrollbarRadiusWhileDragging =
            scrollbarRadiusWhileDragging ?? CupertinoScrollbar.defaultRadiusWhileDragging;

  const PlutoScrollbarConfig.noScroll()
      : draggableScrollbar= false,
        isAlwaysShown = false,
        scrollbarRadius= CupertinoScrollbar.defaultRadius,
        scrollbarRadiusWhileDragging= CupertinoScrollbar.defaultRadiusWhileDragging,
        scrollbarThickness= null,
        scrollbarThicknessWhileDragging= CupertinoScrollbar.defaultThicknessWhileDragging;

  /// Force use Cupertino scrollbars regardless of target platform.
  final bool draggableScrollbar;
  final bool isAlwaysShown;

  final double scrollbarThickness;
  final double scrollbarThicknessWhileDragging;
  final Radius scrollbarRadius;
  final Radius scrollbarRadiusWhileDragging;
}