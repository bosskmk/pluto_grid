part of '../pluto_grid.dart';

class PlutoConfiguration {
  /// border between columns.
  final bool enableColumnBorder;

  final Color gridBackgroundColor;

  /// Grid border color. (Grid outline color, Frozen column division line color)
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

  /// Height of a row.
  final double rowHeight;

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
    this.rowHeight = PlutoDefaultSettings.rowHeight,
    this.enableMoveDownAfterSelecting = true,
    this.enterKeyAction = PlutoEnterKeyAction.editingAndMoveDown,
    this.localeText = const PlutoGridLocaleText(),
    this.scrollbarConfig = const PlutoScrollbarConfig(),
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
    this.rowHeight = PlutoDefaultSettings.rowHeight,
    this.enableMoveDownAfterSelecting = true,
    this.enterKeyAction = PlutoEnterKeyAction.editingAndMoveDown,
    this.localeText = const PlutoGridLocaleText(),
    this.scrollbarConfig = const PlutoScrollbarConfig(),
  });

  PlutoConfiguration copyWith({
    bool enableColumnBorder,
    Color gridBackgroundColor,
    Color gridBorderColor,
    Color activatedColor,
    Color activatedBorderColor,
    Color checkedColor,
    Color borderColor,
    Color cellColorInEditState,
    Color cellColorInReadOnlyState,
    TextStyle columnTextStyle,
    TextStyle cellTextStyle,
    Color iconColor,
    Color menuBackgroundColor,
    double rowHeight,
    bool enableMoveDownAfterSelecting,
    PlutoEnterKeyAction enterKeyAction,
    PlutoGridLocaleText localeText,
    PlutoScrollbarConfig scrollbarConfig,
  }) {
    return PlutoConfiguration(
      enableColumnBorder: enableColumnBorder ?? this.enableColumnBorder,
      gridBackgroundColor: gridBackgroundColor ?? this.gridBackgroundColor,
      gridBorderColor: gridBorderColor ?? this.gridBorderColor,
      activatedColor: activatedColor ?? this.activatedColor,
      activatedBorderColor: activatedBorderColor ?? this.activatedBorderColor,
      checkedColor: checkedColor ?? this.checkedColor,
      borderColor: borderColor ?? this.borderColor,
      cellColorInEditState: cellColorInEditState ?? this.cellColorInEditState,
      cellColorInReadOnlyState:
          cellColorInReadOnlyState ?? this.cellColorInReadOnlyState,
      columnTextStyle: columnTextStyle ?? this.columnTextStyle,
      cellTextStyle: cellTextStyle ?? this.cellTextStyle,
      iconColor: iconColor ?? this.iconColor,
      menuBackgroundColor: menuBackgroundColor ?? this.menuBackgroundColor,
      rowHeight: rowHeight ?? this.rowHeight,
      enableMoveDownAfterSelecting:
          enableMoveDownAfterSelecting ?? this.enableMoveDownAfterSelecting,
      enterKeyAction: enterKeyAction ?? this.enterKeyAction,
      localeText: localeText ?? this.localeText,
      scrollbarConfig: scrollbarConfig ?? this.scrollbarConfig,
    );
  }
}

class PlutoGridLocaleText {
  // Column menu
  final String unfreezeColumn;
  final String freezeColumnToLeft;
  final String freezeColumnToRight;
  final String autoFitColumn;

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

  // Common
  final String loadingText;

  const PlutoGridLocaleText({
    // Column menu
    this.unfreezeColumn = 'Unfreeze',
    this.freezeColumnToLeft = 'FreezeToLeft',
    this.freezeColumnToRight = 'FreezeToRight',
    this.autoFitColumn = 'AutoFit',
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
    // Common
    this.loadingText = 'Loading...',
  });

  const PlutoGridLocaleText.korean({
    // Column menu
    this.unfreezeColumn = '고정 해제',
    this.freezeColumnToLeft = '왼쪽 고정',
    this.freezeColumnToRight = '오른쪽 고정',
    this.autoFitColumn = '넓이 자동 조정',
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
    // Common
    this.loadingText = '로딩중...',
  });

  const PlutoGridLocaleText.russian({
    // Column menu
    this.unfreezeColumn = 'Открепить',
    this.freezeColumnToLeft = 'Закрепить слева',
    this.freezeColumnToRight = 'Закрепить справа',
    this.autoFitColumn = 'Автоматический размер',
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
    // Common
    this.loadingText = 'Загрузка...',
  });

  const PlutoGridLocaleText.czech({
    // Column menu
    this.unfreezeColumn = 'Uvolnit',
    this.freezeColumnToLeft = 'Ukotvit vlevo',
    this.freezeColumnToRight = 'Ukotvit vpravo',
    this.autoFitColumn = 'Autom. přizpůsobit',
    // Date popup
    this.sunday = 'Ne',
    this.monday = 'Po',
    this.tuesday = 'Út',
    this.wednesday = 'St',
    this.thursday = 'Čt',
    this.friday = 'Pá',
    this.saturday = 'So',
    // Time column popup
    this.hour = 'Hodina',
    this.minute = 'Minuta',
    // Common
    this.loadingText = 'Načítání...',
  });
}

enum PlutoEnterKeyAction {
  editingAndMoveDown,
  editingAndMoveRight,
  toggleEditing,
  none,
}

extension PlutoEnterKeyActionExtension on PlutoEnterKeyAction {
  bool get isEditingAndMoveDown =>
      this == PlutoEnterKeyAction.editingAndMoveDown;

  bool get isEditingAndMoveRight =>
      this == PlutoEnterKeyAction.editingAndMoveRight;

  bool get isToggleEditing => this == PlutoEnterKeyAction.toggleEditing;

  bool get isNone => this == null || this == PlutoEnterKeyAction.none;
}

/// Allows to customise scrollbars "look and feel"
/// The general feature is making vertical scrollbar draggable and therefore more useful
/// for desktop systems. Set [draggableScrollbar] to true to achieve this behavior. Also
/// changing [isAlwaysShown] to true is recommended for more usability at desktops.
class PlutoScrollbarConfig {
  const PlutoScrollbarConfig({
    this.draggableScrollbar = true,
    this.isAlwaysShown = false,
    this.scrollbarRadius = CupertinoScrollbar.defaultRadius,
    this.scrollbarRadiusWhileDragging =
        CupertinoScrollbar.defaultRadiusWhileDragging,
    this.scrollbarThickness = CupertinoScrollbar.defaultThickness,
    this.scrollbarThicknessWhileDragging =
        CupertinoScrollbar.defaultThicknessWhileDragging,
  });

  final bool draggableScrollbar;
  final bool isAlwaysShown;
  final double scrollbarThickness;
  final double scrollbarThicknessWhileDragging;
  final Radius scrollbarRadius;
  final Radius scrollbarRadiusWhileDragging;
}
