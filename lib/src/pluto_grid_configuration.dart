import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'helper/filter_helper.dart';

class PlutoGridConfiguration {
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

  /// Icon size. (column menu, cell of popup type)
  final double iconSize;

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
  final PlutoGridEnterKeyAction enterKeyAction;

  final PlutoGridLocaleText localeText;

  /// Customise scrollbars for desktop usage
  final PlutoGridScrollbarConfig scrollbarConfig;

  /// Customise filter of columns
  final PlutoGridColumnFilterConfig columnFilterConfig;

  /// Customise filter of columns
  final PlutoGridSettings settings;

  PlutoGridConfiguration({
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
    this.iconSize = 18,
    this.menuBackgroundColor = Colors.white,
    this.rowHeight = PlutoGridSettings.defaultRowHeight,
    this.enableMoveDownAfterSelecting = true,
    this.enterKeyAction = PlutoGridEnterKeyAction.editingAndMoveDown,
    this.localeText = const PlutoGridLocaleText(),
    this.scrollbarConfig = const PlutoGridScrollbarConfig(),
    this.columnFilterConfig = const PlutoGridColumnFilterConfig(),
    this.settings = const PlutoGridSettings(),
  }) {
    _init();
  }

  PlutoGridConfiguration.dark({
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
    this.iconSize = 18,
    this.menuBackgroundColor = const Color(0xFF414141),
    this.rowHeight = PlutoGridSettings.defaultRowHeight,
    this.enableMoveDownAfterSelecting = true,
    this.enterKeyAction = PlutoGridEnterKeyAction.editingAndMoveDown,
    this.localeText = const PlutoGridLocaleText(),
    this.scrollbarConfig = const PlutoGridScrollbarConfig(),
    this.columnFilterConfig = const PlutoGridColumnFilterConfig(),
    this.settings = const PlutoGridSettings(),
  }) {
    _init();
  }

  void _init() {
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
    Color? gridBackgroundColor,
    Color? gridBorderColor,
    Color? activatedColor,
    Color? activatedBorderColor,
    Color? checkedColor,
    Color? borderColor,
    Color? cellColorInEditState,
    Color? cellColorInReadOnlyState,
    TextStyle? columnTextStyle,
    TextStyle? cellTextStyle,
    Color? iconColor,
    Color? menuBackgroundColor,
    double? rowHeight,
    bool? enableMoveDownAfterSelecting,
    PlutoGridEnterKeyAction? enterKeyAction,
    PlutoGridLocaleText? localeText,
    PlutoGridScrollbarConfig? scrollbarConfig,
    PlutoGridColumnFilterConfig? columnFilterConfig,
  }) {
    return PlutoGridConfiguration(
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
      columnFilterConfig: columnFilterConfig ?? this.columnFilterConfig,
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
    this.loadingText = 'Loading...',
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
    this.loadingText = '加载中...',
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
    this.loadingText = '로딩중...',
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
    this.loadingText = 'Загрузка...',
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
    this.loadingText = 'Načítání...',
  });
}

enum PlutoGridEnterKeyAction {
  editingAndMoveDown,
  editingAndMoveRight,
  toggleEditing,
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
  })  : _userFilters = filters,
        _userResolveDefaultColumnFilter = resolveDefaultColumnFilter;

  final List<PlutoFilterType>? _userFilters;

  final PlutoGridResolveDefaultColumnFilter? _userResolveDefaultColumnFilter;

  bool get hasUserFilter => _userFilters != null && _userFilters!.isNotEmpty;

  List<PlutoFilterType>? get filters =>
      hasUserFilter ? _userFilters : FilterHelper.defaultFilters;

  PlutoFilterType resolver<T>() {
    return filters!.firstWhereOrNull(
          (element) => element.runtimeType == T,
        ) ??
        filters!.first;
  }

  PlutoFilterType getDefaultColumnFilter(PlutoColumn column) {
    if (_userResolveDefaultColumnFilter == null) {
      return filters!.first;
    }

    var resolvedFilter = _userResolveDefaultColumnFilter!(column, resolver);

    assert(filters!.contains(resolvedFilter));

    return resolvedFilter;
  }
}
