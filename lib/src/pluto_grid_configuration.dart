import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridConfiguration {
  /// border between columns.
  final bool enableColumnBorder;

  /// Activate the shadow that separates each area of the grid.
  final bool enableGridBorderShadow;

  /// When you select a value in the pop-up grid, it moves down.
  final bool enableMoveDownAfterSelecting;

  /// Moves the current cell when focus reaches the left or right edge in the edit state.
  final bool enableMoveHorizontalInEditing;

  /// Animation of background color transition of rows,
  /// such as when the current row or rows are dragged.
  final bool enableRowColorAnimation;

  final Color gridBackgroundColor;

  /// Grid border color. (Grid outline color, Frozen column division line color)
  final Color gridBorderColor;

  /// Activated Color. (Current or Selected row, cell)
  final Color activatedColor;

  /// Activated Border Color. (Current cell)
  final Color activatedBorderColor;

  /// Inactivated Border Color. (Current cell)
  final Color inactivatedBorderColor;

  /// Checked Color. (Checked rows)
  final Color checkedColor;

  /// Row border color. (horizontal row border, vertical column border)
  final Color borderColor;

  /// Cell color in edit state. (only current cell)
  final Color cellColorInEditState;

  /// Cell color in read-only state
  final Color cellColorInReadOnlyState;

  /// The background color of the column to be dragged.
  /// When moving a column by dragging it.
  final Color dragTargetColumnColor;

  /// Icon color. (column menu, cell of popup type, pagination plugin)
  final Color iconColor;

  /// Disabled icon color. (pagination plugin)
  final Color disabledIconColor;

  /// BackgroundColor of Popup menu. (column menu)
  final Color menuBackgroundColor;

  /// Column - text style
  final TextStyle columnTextStyle;

  /// Cell - text style
  final TextStyle cellTextStyle;

  /// Icon that can open a pop-up menu next to the column title
  /// when [enableContextMenu] of [PlutoColumn] is true.
  final IconData columnContextIcon;

  /// If enableContextMenu of PlutoColumn is false and enableDropToResize is true,
  /// only the width of the column can be adjusted.
  final IconData columnResizeIcon;

  /// Icon size. (column menu, cell of popup type)
  final double iconSize;

  /// Height of a row.
  final double rowHeight;

  /// Height of column.
  final double columnHeight;

  /// Height of column filter.
  final double columnFilterHeight;

  /// Customise column title padding
  /// If there is no titlePadding of PlutoColumn,
  /// it is the title padding of the default column.
  final EdgeInsets defaultColumnTitlePadding;

  /// Customise cell padding
  /// If there is no cellPadding of PlutoColumn,
  /// it is the padding value of cell.
  final EdgeInsets defaultCellPadding;

  /// Grid corners can be rounded.
  final BorderRadiusGeometry gridBorderRadius;

  /// The corners of the popup-type grid used inside the grid can be rounded.
  final BorderRadiusGeometry gridPopupBorderRadius;

  /// [PlutoEnterKeyAction.EditingAndMoveDown]
  /// It switches to the editing state, and moves down in the editing state.
  ///
  /// [PlutoEnterKeyAction.EditingAndMoveRight]
  /// It switches to the editing state, and moves to the right in the editing state.
  ///
  /// [PlutoEnterKeyAction.ToggleEditing]
  /// The editing state is toggled and cells are not moved.
  ///
  /// [PlutoEnterKeyAction.None]
  /// There is no action.
  final PlutoGridEnterKeyAction enterKeyAction;

  final PlutoGridLocaleText localeText;

  /// Customise scrollbars for desktop usage
  final PlutoGridScrollbarConfig scrollbarConfig;

  /// Customise filter of columns
  final PlutoGridColumnFilterConfig columnFilterConfig;

  final PlutoGridColumnSizeConfig columnSizeConfig;

  const PlutoGridConfiguration({
    this.enableColumnBorder = false,
    this.enableGridBorderShadow = false,
    this.enableMoveDownAfterSelecting = false,
    this.enableMoveHorizontalInEditing = false,
    this.enableRowColorAnimation = true,
    this.gridBackgroundColor = Colors.white,
    this.gridBorderColor = const Color(0xFFA1A5AE),
    this.activatedColor = const Color(0xFFDCF5FF),
    this.activatedBorderColor = Colors.lightBlue,
    this.inactivatedBorderColor = const Color(0xFFC4C7CC),
    this.checkedColor = const Color(0x11757575),
    this.borderColor = const Color(0xFFDDE2EB),
    this.cellColorInEditState = Colors.white,
    this.cellColorInReadOnlyState = const Color(0xFFC4C7CC),
    this.dragTargetColumnColor = const Color(0xFFDCF5FF),
    this.iconColor = Colors.black26,
    this.disabledIconColor = Colors.black12,
    this.menuBackgroundColor = Colors.white,
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
    this.columnContextIcon = Icons.dehaze,
    this.columnResizeIcon = Icons.code_sharp,
    this.iconSize = 18,
    this.rowHeight = PlutoGridSettings.rowHeight,
    this.columnHeight = PlutoGridSettings.rowHeight,
    this.columnFilterHeight = PlutoGridSettings.rowHeight,
    this.defaultColumnTitlePadding = PlutoGridSettings.columnTitlePadding,
    this.defaultCellPadding = PlutoGridSettings.cellPadding,
    this.gridBorderRadius = BorderRadius.zero,
    this.gridPopupBorderRadius = BorderRadius.zero,
    this.enterKeyAction = PlutoGridEnterKeyAction.editingAndMoveDown,
    this.localeText = const PlutoGridLocaleText(),
    this.scrollbarConfig = const PlutoGridScrollbarConfig(),
    this.columnFilterConfig = const PlutoGridColumnFilterConfig(),
    this.columnSizeConfig = const PlutoGridColumnSizeConfig(),
  });

  const PlutoGridConfiguration.dark({
    this.enableColumnBorder = false,
    this.enableGridBorderShadow = false,
    this.enableMoveDownAfterSelecting = false,
    this.enableMoveHorizontalInEditing = false,
    this.enableRowColorAnimation = true,
    this.gridBackgroundColor = const Color(0xFF111111),
    this.gridBorderColor = const Color(0xFF666666),
    this.activatedColor = const Color(0xFF313131),
    this.activatedBorderColor = const Color(0xFFFFFFFF),
    this.inactivatedBorderColor = const Color(0xFF666666),
    this.checkedColor = const Color(0x11202020),
    this.borderColor = const Color(0xFF222222),
    this.cellColorInEditState = const Color(0xFF666666),
    this.cellColorInReadOnlyState = const Color(0xFF222222),
    this.dragTargetColumnColor = const Color(0xFF313131),
    this.iconColor = Colors.white38,
    this.disabledIconColor = Colors.white12,
    this.menuBackgroundColor = const Color(0xFF414141),
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
    this.columnContextIcon = Icons.dehaze,
    this.columnResizeIcon = Icons.code_sharp,
    this.iconSize = 18,
    this.rowHeight = PlutoGridSettings.rowHeight,
    this.columnHeight = PlutoGridSettings.rowHeight,
    this.columnFilterHeight = PlutoGridSettings.rowHeight,
    this.defaultColumnTitlePadding = PlutoGridSettings.columnTitlePadding,
    this.defaultCellPadding = PlutoGridSettings.cellPadding,
    this.gridBorderRadius = BorderRadius.zero,
    this.gridPopupBorderRadius = BorderRadius.zero,
    this.enterKeyAction = PlutoGridEnterKeyAction.editingAndMoveDown,
    this.localeText = const PlutoGridLocaleText(),
    this.scrollbarConfig = const PlutoGridScrollbarConfig(),
    this.columnFilterConfig = const PlutoGridColumnFilterConfig(),
    this.columnSizeConfig = const PlutoGridColumnSizeConfig(),
  });

  void updateLocale() {
    PlutoFilterTypeContains.name = localeText.filterContains;
    PlutoFilterTypeEquals.name = localeText.filterEquals;
    PlutoFilterTypeStartsWith.name = localeText.filterStartsWith;
    PlutoFilterTypeEndsWith.name = localeText.filterEndsWith;
    PlutoFilterTypeGreaterThan.name = localeText.filterGreaterThan;
    PlutoFilterTypeGreaterThanOrEqualTo.name =
        localeText.filterGreaterThanOrEqualTo;
    PlutoFilterTypeLessThan.name = localeText.filterLessThan;
    PlutoFilterTypeLessThanOrEqualTo.name = localeText.filterLessThanOrEqualTo;
  }

  /// Fired when setConfiguration is called in [PlutoGridStateManager]'s constructor.
  void applyColumnFilter(List<PlutoColumn>? refColumns) {
    if (refColumns == null || refColumns.isEmpty) {
      return;
    }

    var len = refColumns.length;

    for (var i = 0; i < len; i += 1) {
      var column = refColumns[i];

      column.setDefaultFilter(
        columnFilterConfig.getDefaultColumnFilter(column),
      );
    }
  }

  PlutoGridConfiguration copyWith({
    bool? enableColumnBorder,
    bool? enableGridBorderShadow,
    bool? enableMoveDownAfterSelecting,
    bool? enableMoveHorizontalInEditing,
    bool? enableRowColorAnimation,
    Color? gridBackgroundColor,
    Color? gridBorderColor,
    Color? activatedColor,
    Color? activatedBorderColor,
    Color? inactivatedBorderColor,
    Color? checkedColor,
    Color? borderColor,
    Color? cellColorInEditState,
    Color? cellColorInReadOnlyState,
    Color? dragTargetColumnColor,
    Color? iconColor,
    Color? disabledIconColor,
    Color? menuBackgroundColor,
    TextStyle? columnTextStyle,
    TextStyle? cellTextStyle,
    IconData? columnContextIcon,
    IconData? columnResizeIcon,
    double? iconSize,
    double? rowHeight,
    double? columnHeight,
    double? columnFilterHeight,
    EdgeInsets? defaultColumnTitlePadding,
    EdgeInsets? defaultCellPadding,
    BorderRadiusGeometry? gridBorderRadius,
    BorderRadiusGeometry? gridPopupBorderRadius,
    PlutoGridEnterKeyAction? enterKeyAction,
    PlutoGridLocaleText? localeText,
    PlutoGridScrollbarConfig? scrollbarConfig,
    PlutoGridColumnFilterConfig? columnFilterConfig,
    PlutoGridColumnSizeConfig? columnSizeConfig,
  }) {
    return PlutoGridConfiguration(
      enableColumnBorder: enableColumnBorder ?? this.enableColumnBorder,
      enableGridBorderShadow:
          enableGridBorderShadow ?? this.enableGridBorderShadow,
      enableMoveDownAfterSelecting:
          enableMoveDownAfterSelecting ?? this.enableMoveDownAfterSelecting,
      enableMoveHorizontalInEditing:
          enableMoveHorizontalInEditing ?? this.enableMoveHorizontalInEditing,
      enableRowColorAnimation:
          enableRowColorAnimation ?? this.enableRowColorAnimation,
      gridBackgroundColor: gridBackgroundColor ?? this.gridBackgroundColor,
      gridBorderColor: gridBorderColor ?? this.gridBorderColor,
      activatedColor: activatedColor ?? this.activatedColor,
      activatedBorderColor: activatedBorderColor ?? this.activatedBorderColor,
      inactivatedBorderColor:
          inactivatedBorderColor ?? this.inactivatedBorderColor,
      checkedColor: checkedColor ?? this.checkedColor,
      borderColor: borderColor ?? this.borderColor,
      cellColorInEditState: cellColorInEditState ?? this.cellColorInEditState,
      cellColorInReadOnlyState:
          cellColorInReadOnlyState ?? this.cellColorInReadOnlyState,
      dragTargetColumnColor:
          dragTargetColumnColor ?? this.dragTargetColumnColor,
      iconColor: iconColor ?? this.iconColor,
      disabledIconColor: disabledIconColor ?? this.disabledIconColor,
      menuBackgroundColor: menuBackgroundColor ?? this.menuBackgroundColor,
      columnTextStyle: columnTextStyle ?? this.columnTextStyle,
      cellTextStyle: cellTextStyle ?? this.cellTextStyle,
      columnContextIcon: columnContextIcon ?? this.columnContextIcon,
      columnResizeIcon: columnResizeIcon ?? this.columnResizeIcon,
      iconSize: iconSize ?? this.iconSize,
      rowHeight: rowHeight ?? this.rowHeight,
      columnHeight: columnHeight ?? this.columnHeight,
      columnFilterHeight: columnFilterHeight ?? this.columnFilterHeight,
      defaultColumnTitlePadding:
          defaultColumnTitlePadding ?? this.defaultColumnTitlePadding,
      defaultCellPadding: defaultCellPadding ?? this.defaultCellPadding,
      gridBorderRadius: gridBorderRadius ?? this.gridBorderRadius,
      gridPopupBorderRadius:
          gridPopupBorderRadius ?? this.gridPopupBorderRadius,
      enterKeyAction: enterKeyAction ?? this.enterKeyAction,
      localeText: localeText ?? this.localeText,
      scrollbarConfig: scrollbarConfig ?? this.scrollbarConfig,
      columnFilterConfig: columnFilterConfig ?? this.columnFilterConfig,
      columnSizeConfig: columnSizeConfig ?? this.columnSizeConfig,
    );
  }
}

class PlutoGridLocaleText {
  // Column menu
  final String unfreezeColumn;
  final String freezeColumnToLeft;
  final String freezeColumnToRight;
  final String autoFitColumn;
  final String hideColumn;
  final String setColumns;
  final String setFilter;
  final String resetFilter;

  // SetColumns popup
  final String setColumnsTitle;

  // Filter popup
  final String filterColumn;
  final String filterType;
  final String filterValue;
  final String filterAllColumns;
  final String filterContains;
  final String filterEquals;
  final String filterStartsWith;
  final String filterEndsWith;
  final String filterGreaterThan;
  final String filterGreaterThanOrEqualTo;
  final String filterLessThan;
  final String filterLessThanOrEqualTo;

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
    this.freezeColumnToLeft = 'Freeze to left',
    this.freezeColumnToRight = 'Freeze to right',
    this.autoFitColumn = 'Auto fit',
    this.hideColumn = 'Hide column',
    this.setColumns = 'Set columns',
    this.setFilter = 'Set filter',
    this.resetFilter = 'Reset filter',
    // SetColumns popup
    this.setColumnsTitle = 'Column title',
    // Filter popup
    this.filterColumn = 'Column',
    this.filterType = 'Type',
    this.filterValue = 'Value',
    this.filterAllColumns = 'All columns',
    this.filterContains = 'Contains',
    this.filterEquals = 'Equals',
    this.filterStartsWith = 'Starts with',
    this.filterEndsWith = 'Ends with',
    this.filterGreaterThan = 'Greater than',
    this.filterGreaterThanOrEqualTo = 'Greater than or equal to',
    this.filterLessThan = 'Less than',
    this.filterLessThanOrEqualTo = 'Less than or equal to',
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
    this.loadingText = 'Loading',
  });

  const PlutoGridLocaleText.china({
    // Column menu
    this.unfreezeColumn = '解冻',
    this.freezeColumnToLeft = '冻结至左侧',
    this.freezeColumnToRight = '冻结至右侧',
    this.autoFitColumn = '自动列宽',
    this.hideColumn = '隐藏列',
    this.setColumns = '设置列',
    this.setFilter = '设置过滤器',
    this.resetFilter = '重置过滤器',
    // SetColumns popup
    this.setColumnsTitle = '列标题',
    // Filter popup
    this.filterColumn = '列',
    this.filterType = '类型',
    this.filterValue = '值',
    this.filterAllColumns = '全部列',
    this.filterContains = '包含',
    this.filterEquals = '等于',
    this.filterStartsWith = '开始于',
    this.filterEndsWith = '结束于',
    this.filterGreaterThan = '大于',
    this.filterGreaterThanOrEqualTo = '大于等于',
    this.filterLessThan = '小于',
    this.filterLessThanOrEqualTo = '小于等于',
    // Date popup
    this.sunday = '日',
    this.monday = '一',
    this.tuesday = '四',
    this.wednesday = '三',
    this.thursday = '二',
    this.friday = '五',
    this.saturday = '六',
    // Time column popup
    this.hour = '时',
    this.minute = '分',
    // Common
    this.loadingText = '加载中',
  });

  const PlutoGridLocaleText.korean({
    // Column menu
    this.unfreezeColumn = '고정 해제',
    this.freezeColumnToLeft = '왼쪽 고정',
    this.freezeColumnToRight = '오른쪽 고정',
    this.autoFitColumn = '넓이 자동 조정',
    this.hideColumn = '컬럼 숨기기',
    this.setColumns = '컬럼 설정',
    this.setFilter = '필터 설정',
    this.resetFilter = '필터 초기화',
    // SetColumns popup
    this.setColumnsTitle = '컬럼명',
    // Filter popup
    this.filterColumn = '컬럼',
    this.filterType = '종류',
    this.filterValue = '값',
    this.filterAllColumns = '전체 컬럼',
    this.filterContains = '포함',
    this.filterEquals = '일치',
    this.filterStartsWith = '~로 시작',
    this.filterEndsWith = '~로 끝',
    this.filterGreaterThan = '~보다 큰',
    this.filterGreaterThanOrEqualTo = '~보다 크거나 같은',
    this.filterLessThan = '~보다 작은',
    this.filterLessThanOrEqualTo = '~보다 작거나 같은',
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
    this.loadingText = '로딩중',
  });

  const PlutoGridLocaleText.russian({
    // Column menu
    this.unfreezeColumn = 'Открепить',
    this.freezeColumnToLeft = 'Закрепить слева',
    this.freezeColumnToRight = 'Закрепить справа',
    this.autoFitColumn = 'Автоматический размер',
    this.hideColumn = 'Hide column',
    this.setColumns = 'Set columns',
    this.setFilter = 'SetFilter',
    this.resetFilter = 'ResetFilter',
    // SetColumns popup
    this.setColumnsTitle = 'Column title',
    // Filter popup
    this.filterColumn = 'Column',
    this.filterType = 'Type',
    this.filterValue = 'Value',
    this.filterAllColumns = 'All columns',
    this.filterContains = 'Contains',
    this.filterEquals = 'Equals',
    this.filterStartsWith = 'Starts with',
    this.filterEndsWith = 'Ends with',
    this.filterGreaterThan = 'Greater than',
    this.filterGreaterThanOrEqualTo = 'Greater than or equal to',
    this.filterLessThan = 'Less than',
    this.filterLessThanOrEqualTo = 'Less than or equal to',
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
    this.loadingText = 'Загрузка',
  });

  const PlutoGridLocaleText.czech({
    // Column menu
    this.unfreezeColumn = 'Uvolnit',
    this.freezeColumnToLeft = 'Ukotvit vlevo',
    this.freezeColumnToRight = 'Ukotvit vpravo',
    this.autoFitColumn = 'Autom. přizpůsobit',
    this.hideColumn = 'Hide column',
    this.setColumns = 'Set columns',
    this.setFilter = 'SetFilter',
    this.resetFilter = 'ResetFilter',
    // SetColumns popup
    this.setColumnsTitle = 'Column title',
    // Filter popup
    this.filterColumn = 'Column',
    this.filterType = 'Type',
    this.filterValue = 'Value',
    this.filterAllColumns = 'All columns',
    this.filterContains = 'Contains',
    this.filterEquals = 'Equals',
    this.filterStartsWith = 'Starts with',
    this.filterEndsWith = 'Ends with',
    this.filterGreaterThan = 'Greater than',
    this.filterGreaterThanOrEqualTo = 'Greater than or equal to',
    this.filterLessThan = 'Less than',
    this.filterLessThanOrEqualTo = 'Less than or equal to',
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
    this.loadingText = 'Načítání',
  });

  const PlutoGridLocaleText.brazilianPortuguese({
    // Column menu
    this.unfreezeColumn = 'Descongelar',
    this.freezeColumnToLeft = 'Congelar à esquerda',
    this.freezeColumnToRight = 'Congelar à direita',
    this.autoFitColumn = 'Auto Ajustar',
    this.hideColumn = 'Esconder coluna',
    this.setColumns = 'Definir coluneas',
    this.setFilter = 'Definir fitros',
    this.resetFilter = 'Limpar filtros',
    // SetColumns popup
    this.setColumnsTitle = 'Título da coluna',
    // Filter popup
    this.filterColumn = 'Coluna',
    this.filterType = 'Tipo',
    this.filterValue = 'Valor',
    this.filterAllColumns = 'Todas as colunas',
    this.filterContains = 'Contenha',
    this.filterEquals = 'Igual',
    this.filterStartsWith = 'Iniciar com',
    this.filterEndsWith = 'Terminar com',
    this.filterGreaterThan = 'Maior que',
    this.filterGreaterThanOrEqualTo = 'Maior ou igual que',
    this.filterLessThan = 'Menor que',
    this.filterLessThanOrEqualTo = 'Menor ou igual que',
    // Date popup
    this.sunday = 'Dom',
    this.monday = 'Seg',
    this.tuesday = 'Ter',
    this.wednesday = 'Qua',
    this.thursday = 'Qui',
    this.friday = 'Sex',
    this.saturday = 'Sab',
    // Time column popup
    this.hour = 'Hora',
    this.minute = 'Minuto',
    // Common
    this.loadingText = 'Carregando',
  });

  const PlutoGridLocaleText.spanish({
    // Column menu
    this.unfreezeColumn = 'Descongelar',
    this.freezeColumnToLeft = 'Congelar a la izquierda',
    this.freezeColumnToRight = 'Congelar a la derecha',
    this.autoFitColumn = 'Autoajuste',
    this.hideColumn = 'Ocultar columna',
    this.setColumns = 'Eligir columnas',
    this.setFilter = 'Definir fitros',
    this.resetFilter = 'Limpiar filtros',
    // SetColumns popup
    this.setColumnsTitle = 'Título de la columna',
    // Filter popup
    this.filterColumn = 'Columna',
    this.filterType = 'Tipo',
    this.filterValue = 'Valor',
    this.filterAllColumns = 'Todas las columnas',
    this.filterContains = 'Contenga',
    this.filterEquals = 'Igual',
    this.filterStartsWith = 'Empezar con',
    this.filterEndsWith = 'Terminar con',
    this.filterGreaterThan = 'Más grande que',
    this.filterGreaterThanOrEqualTo = 'Más grande o igual que',
    this.filterLessThan = 'Más pequeño que',
    this.filterLessThanOrEqualTo = 'Más pequeño o igual que',
    // Date popup
    this.sunday = 'Dom',
    this.monday = 'Lu',
    this.tuesday = 'Ma',
    this.wednesday = 'Mi',
    this.thursday = 'Ju',
    this.friday = 'Vi',
    this.saturday = 'Sa',
    // Time column popup
    this.hour = 'Hora',
    this.minute = 'Minuto',
    // Common
    this.loadingText = 'Cargando',
  });

  const PlutoGridLocaleText.persian({
    // Column menu
    this.unfreezeColumn = 'جدا کردن',
    this.freezeColumnToLeft = 'چسباندن به چپ',
    this.freezeColumnToRight = 'چسباندن به راست',
    this.autoFitColumn = 'عرض خودکار',
    this.hideColumn = 'مخفی کردن ستون',
    this.setColumns = 'تنظیم ستون ها',
    this.setFilter = 'اعمال فیلتر',
    this.resetFilter = 'ریست فیلتر',
    // SetColumns popup
    this.setColumnsTitle = 'عنوان ستون',
    // Filter popup
    this.filterColumn = 'ستون',
    this.filterType = 'نوع',
    this.filterValue = 'مقدار',
    this.filterAllColumns = 'تمام ستون ها',
    this.filterContains = 'شامل',
    this.filterEquals = 'برابر',
    this.filterStartsWith = 'شروع با',
    this.filterEndsWith = 'خاتمه با',
    this.filterGreaterThan = 'بزرگتر از',
    this.filterGreaterThanOrEqualTo = 'بزرگتر مساوی از',
    this.filterLessThan = 'کمتر از',
    this.filterLessThanOrEqualTo = 'کمتر مساوی از',
    // Date popup
    this.sunday = 'ی',
    this.monday = 'د',
    this.tuesday = 'س',
    this.wednesday = 'چ',
    this.thursday = 'پ',
    this.friday = 'ج',
    this.saturday = 'ش',
    // Time column popup
    this.hour = 'ساعت',
    this.minute = 'دقیقه',
    // Common
    this.loadingText = 'در حال بارگیری',
  });
}

/// Behavior of the Enter key when a cell is selected.
enum PlutoGridEnterKeyAction {
  /// When the Enter key is pressed, the cell is changed to the edit state,
  /// or if it is already in the edit state, it moves to the cell below.
  editingAndMoveDown,

  /// When the Enter key is pressed, the cell is changed to the edit state,
  /// or if it is already in the edit state, it moves to the right cell.
  editingAndMoveRight,

  /// Pressing the Enter key toggles the editing status.
  toggleEditing,

  /// Pressing the Enter key does nothing.
  none,
}

extension PlutoGridEnterKeyActionExtension on PlutoGridEnterKeyAction {
  bool get isEditingAndMoveDown =>
      this == PlutoGridEnterKeyAction.editingAndMoveDown;

  bool get isEditingAndMoveRight =>
      this == PlutoGridEnterKeyAction.editingAndMoveRight;

  bool get isToggleEditing => this == PlutoGridEnterKeyAction.toggleEditing;

  bool get isNone => this == PlutoGridEnterKeyAction.none;
}

/// Allows to customise scrollbars "look and feel"
/// The general feature is making vertical scrollbar draggable and therefore more useful
/// for desktop systems. Set [draggableScrollbar] to true to achieve this behavior. Also
/// changing [isAlwaysShown] to true is recommended for more usability at desktops.
class PlutoGridScrollbarConfig {
  const PlutoGridScrollbarConfig({
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

typedef PlutoGridColumnFilterResolver = Function<T>();

typedef PlutoGridResolveDefaultColumnFilter = PlutoFilterType Function(
  PlutoColumn column,
  PlutoGridColumnFilterResolver resolver,
);

class PlutoGridColumnFilterConfig {
  /// # Set the filter information of the column.
  ///
  /// **Return the value returned by [resolveDefaultColumnFilter] through the resolver function.**
  /// **Prevents errors returning filter that are not in the [filters] list.**
  ///
  /// The value of returning from resolveDefaultColumnFilter
  /// becomes the condition of TextField below the column or
  /// is set as the default filter when calling the column popup.
  ///
  /// ```dart
  ///
  /// var filterConfig = PlutoColumnFilterConfig(
  ///   filters: const [
  ///     ...FilterHelper.defaultFilters,
  ///     // custom filter
  ///     ClassYouImplemented(),
  ///   ],
  ///   resolveDefaultColumnFilter: (column, resolver) {
  ///     if (column.field == 'text') {
  ///       return resolver<PlutoFilterTypeContains>();
  ///     } else if (column.field == 'number') {
  ///       return resolver<PlutoFilterTypeGreaterThan>();
  ///     } else if (column.field == 'date') {
  ///       return resolver<PlutoFilterTypeLessThan>();
  ///     } else if (column.field == 'select') {
  ///       return resolver<ClassYouImplemented>();
  ///     }
  ///
  ///     return resolver<PlutoFilterTypeContains>();
  ///   },
  /// );
  ///
  /// class ClassYouImplemented implements PlutoFilterType {
  ///   String get title => 'Custom contains';
  ///
  ///   get compare => ({
  ///         String base,
  ///         String search,
  ///         PlutoColumn column,
  ///       }) {
  ///         var keys = search.split(',').map((e) => e.toUpperCase()).toList();
  ///
  ///         return keys.contains(base.toUpperCase());
  ///       };
  ///
  ///   const ClassYouImplemented();
  /// }
  /// ```
  const PlutoGridColumnFilterConfig({
    List<PlutoFilterType>? filters,
    PlutoGridResolveDefaultColumnFilter? resolveDefaultColumnFilter,
    int? debounceMilliseconds,
  })  : _userFilters = filters,
        _userResolveDefaultColumnFilter = resolveDefaultColumnFilter,
        _debounceMilliseconds = debounceMilliseconds == null
            ? PlutoGridSettings.debounceMillisecondsForColumnFilter
            : debounceMilliseconds < 0
                ? 0
                : debounceMilliseconds;

  final List<PlutoFilterType>? _userFilters;

  final PlutoGridResolveDefaultColumnFilter? _userResolveDefaultColumnFilter;

  final int _debounceMilliseconds;

  bool get hasUserFilter => _userFilters != null && _userFilters!.isNotEmpty;

  List<PlutoFilterType> get filters =>
      hasUserFilter ? _userFilters! : FilterHelper.defaultFilters;

  int get debounceMilliseconds => _debounceMilliseconds;

  PlutoFilterType resolver<T>() {
    return filters.firstWhereOrNull(
          (element) => element.runtimeType == T,
        ) ??
        filters.first;
  }

  PlutoFilterType getDefaultColumnFilter(PlutoColumn column) {
    if (_userResolveDefaultColumnFilter == null) {
      return filters.first;
    }

    var resolvedFilter = _userResolveDefaultColumnFilter!(column, resolver);

    assert(filters.contains(resolvedFilter));

    return resolvedFilter;
  }
}

class PlutoGridColumnSizeConfig {
  const PlutoGridColumnSizeConfig({
    this.autoSizeMode = PlutoAutoSizeMode.none,
    this.resizeMode = PlutoResizeMode.normal,
    this.restoreAutoSizeAfterHideColumn = true,
    this.restoreAutoSizeAfterFrozenColumn = true,
    this.restoreAutoSizeAfterMoveColumn = true,
    this.restoreAutoSizeAfterInsertColumn = true,
    this.restoreAutoSizeAfterRemoveColumn = true,
  });

  final PlutoAutoSizeMode autoSizeMode;

  final PlutoResizeMode resizeMode;

  final bool restoreAutoSizeAfterHideColumn;

  final bool restoreAutoSizeAfterFrozenColumn;

  final bool restoreAutoSizeAfterMoveColumn;

  final bool restoreAutoSizeAfterInsertColumn;

  final bool restoreAutoSizeAfterRemoveColumn;
}
