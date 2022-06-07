import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show Intl;
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

/// [PlutoGrid] is a widget that receives columns and rows and is expressed as a grid-type UI.
///
/// [PlutoGrid] supports movement and editing with the keyboard,
/// Through various settings, it can be transformed and used in various UIs.
///
/// Pop-ups such as date selection, time selection,
/// and option selection used inside [PlutoGrid] are created with the API provided outside of [PlutoGrid].
/// Also, the popup to set the filter or column inside the grid is implemented through the setting of [PlutoGrid].
class PlutoGrid extends StatefulWidget {
  const PlutoGrid({
    Key? key,
    required this.columns,
    required this.rows,
    this.columnGroups,
    this.onLoaded,
    this.onChanged,
    this.onSelected,
    this.onRowChecked,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.onRowsMoved,
    this.createHeader,
    this.createFooter,
    this.rowColorCallback,
    this.configuration,
    this.mode = PlutoGridMode.normal,
  }) : super(key: key);

  /// The [PlutoColumn] column is delivered as a list and can be added or deleted after grid creation.
  ///
  /// Columns can be added or deleted
  /// with [PlutoGridStateManager.insertColumns] and [PlutoGridStateManager.removeColumns].
  ///
  /// Each [PlutoColumn.field] value in [List] must be unique.
  /// [PlutoColumn.field] must be provided to match the map key in [PlutoRow.cells].
  /// should also be provided to match in [PlutoColumnGroup.fields] as well.
  final List<PlutoColumn> columns;

  /// [rows] contains a call to the [PlutoGridStateManager.initializeRows] method
  /// that handles necessary settings when creating a grid or when a new row is added.
  ///
  /// CPU operation is required as much as [rows.length] multiplied by the number of [PlutoRow.cells].
  /// No problem under normal circumstances, but if there are many rows and columns,
  /// the UI may freeze at the start of the grid.
  /// In this case, the grid is started by passing an empty list to rows
  /// and after the [PlutoGrid.onLoaded] callback is called
  /// Rows initialization can be done asynchronously with [PlutoGridStateManager.initializeRowsAsync] .
  ///
  /// ```dart
  /// stateManager.setShowLoading(true);
  ///
  /// PlutoGridStateManager.initializeRowsAsync(
  ///   columns,
  ///   fetchedRows,
  /// ).then((value) {
  ///   stateManager.refRows.addAll(FilteredList(initialList: value));
  ///
  ///   /// In this example,
  ///   /// the loading screen is activated in the onLoaded callback when the grid is created.
  ///   /// If the loading screen is not activated
  ///   /// You must update the grid state by calling the stateManager.notifyListeners() method.
  ///   /// Because calling setShowLoading updates the grid state
  ///   /// No need to call stateManager.notifyListeners.
  ///   stateManager.setShowLoading(false);
  /// });
  /// ```
  final List<PlutoRow> rows;

  /// [columnGroups] can be expressed in UI by grouping columns.
  final List<PlutoColumnGroup>? columnGroups;

  /// When the constructor of [PlutoGrid] works, the callback is answered.
  ///
  /// [onLoaded] can be used to receive [PlutoGridStateManager].
  final PlutoOnLoadedEventCallback? onLoaded;

  /// [onChanged] is called when the cell value changes.
  ///
  /// When changing the cell value directly programmatically
  /// with the [PlutoGridStateManager.changeCellValue] method
  /// When changing the value by calling [callOnChangedEvent]
  /// as false as the parameter of [PlutoGridStateManager.changeCellValue]
  /// The [onChanged] callback is not called.
  final PlutoOnChangedEventCallback? onChanged;

  /// [onSelected] can receive a response only if [PlutoGrid.mode] is set to [PlutoGridMode.select] .
  ///
  /// When a row is tapped or the Enter key is pressed, the row information can be returned.
  /// When [PlutoGrid] is used for row selection, you can use [PlutoGridMode.select] .
  /// Basically, in [PlutoGridMode.select], the [onLoaded] callback works
  /// when the current selected row is tapped or the Enter key is pressed.
  /// This will require a double tap if no row is selected.
  /// In [PlutoGridMode.selectWithOneTap], the [onLoaded] callback works when the unselected row is tapped once.
  final PlutoOnSelectedEventCallback? onSelected;

  /// [onRowChecked] can receive the check status change of the checkbox
  /// when [PlutoColumn.enableRowChecked] is enabled.
  final PlutoOnRowCheckedEventCallback? onRowChecked;

  /// [onRowDoubleTap] is called when a row is tapped twice in a row.
  final PlutoOnRowDoubleTapEventCallback? onRowDoubleTap;

  /// [onRowSecondaryTap] is called when a mouse right-click event occurs.
  final PlutoOnRowSecondaryTapEventCallback? onRowSecondaryTap;

  /// [onRowsMoved] is called after the row is dragged and moved if [PlutoColumn.enableRowDrag] is enabled.
  final PlutoOnRowsMovedEventCallback? onRowsMoved;

  /// [createHeader] is a user-definable area located above the upper column area of [PlutoGrid].
  ///
  /// Just pass a callback that returns [Widget] .
  /// Assuming you created a widget called Header.
  /// ```dart
  /// createHeader: (stateManager) {
  ///   stateManager.headerHeight = 45;
  ///   return Header(
  ///     stateManager: stateManager,
  ///   );
  /// },
  /// ```
  ///
  /// If the widget returned to the callback detects the state and updates the UI,
  /// register the callback in [PlutoGridStateManager.addListener]
  /// and update the UI with [StatefulWidget.setState], etc.
  /// The listener callback registered with [PlutoGridStateManager.addListener]
  /// must remove the listener callback with [PlutoGridStateManager.removeListener]
  /// when the widget returned by the callback is dispose.
  final CreateHeaderCallBack? createHeader;

  /// [createFooter] is equivalent to [createHeader].
  /// However, it is located at the bottom of the grid.
  ///
  /// [CreateFooter] can also be passed an already provided widget for Pagination.
  /// Of course you can pass it to [createHeader] , but it's not a typical UI.
  /// ```dart
  /// createFooter: (stateManager) {
  ///   stateManager.setPageSize(100, notify: false); // default 40
  ///   return PlutoPagination(stateManager);
  /// },
  /// ```
  final CreateFooterCallBack? createFooter;

  /// [rowColorCallback] can change the row background color dynamically according to the state.
  ///
  /// Implement a callback that returns a [Color] by referring to the value passed as a callback argument.
  /// ```dart
  /// rowColorCallback: (rowColorContext) {
  ///   if (rowColorContext.row.cells.entries.elementAt(4).value.value ==
  ///       'One') {
  ///     return Colors.blueAccent;
  ///   } else if (rowColorContext.row.cells.entries
  ///           .elementAt(4)
  ///           .value
  ///           .value ==
  ///       'Two') {
  ///     return Colors.cyanAccent;
  ///   }
  ///   return Colors.deepOrange;
  /// },
  /// ```
  final PlutoRowColorCallback? rowColorCallback;

  /// In [configuration], you can change the style and settings or text used in [PlutoGrid].
  final PlutoGridConfiguration? configuration;

  /// [PlutoGridMode.normal]
  /// Normal grid with cell editing.
  ///
  /// [PlutoGridMode.select]
  /// Editing is not possible, and if you press enter or tap on the list,
  /// you can receive the selected row and cell from the onSelected callback.
  final PlutoGridMode? mode;

  /// [setDefaultLocale] sets locale when [Intl] package is used in [PlutoGrid].
  ///
  /// {@template intl_default_locale}
  /// ```dart
  /// PlutoGrid.setDefaultLocale('es_ES');
  /// PlutoGrid.initializeDateFormat();
  ///
  /// // or if you already use Intl in your app.
  ///
  /// Intl.defaultLocale = 'es_ES';
  /// initializeDateFormatting();
  /// ```
  /// {@endtemplate}
  /// ```
  static setDefaultLocale(String locale) {
    Intl.defaultLocale = locale;
  }

  /// [initializeDateFormat] should be called
  /// when you need to set date format when changing locale.
  ///
  /// {@macro intl_default_locale}
  static initializeDateFormat() {
    initializeDateFormatting();
  }

  @override
  PlutoGridState createState() => PlutoGridState();
}

class PlutoGridState extends State<PlutoGrid> {
  final FocusNode _gridFocusNode = FocusNode();

  final LinkedScrollControllerGroup _verticalScroll =
      LinkedScrollControllerGroup();

  final LinkedScrollControllerGroup _horizontalScroll =
      LinkedScrollControllerGroup();

  final List<Function()> _disposeList = [];

  late final PlutoGridStateManager _stateManager;

  late final PlutoGridKeyManager _keyManager;

  late final PlutoGridEventManager _eventManager;

  bool? _showFrozenColumn;

  bool? _hasLeftFrozenColumns;

  double? _bodyLeftOffset;

  double? _bodyRightOffset;

  bool? _hasRightFrozenColumns;

  double? _rightFrozenLeftOffset;

  bool? _showColumnGroups;

  bool? _showColumnFilter;

  bool? _showLoading;

  Widget? _header;

  Widget? _footer;

  @override
  void dispose() {
    for (var dispose in _disposeList) {
      dispose();
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _disposeList.add(() {
      _gridFocusNode.dispose();
    });

    _initStateManager();

    _initKeyManager();

    _initEventManager();

    _initOnLoadedEvent();

    _initSelectMode();

    _initHeaderFooter();
  }

  void _initStateManager() {
    _stateManager = PlutoGridStateManager(
      columns: widget.columns,
      rows: widget.rows,
      gridFocusNode: _gridFocusNode,
      scroll: PlutoGridScrollController(
        vertical: _verticalScroll,
        horizontal: _horizontalScroll,
      ),
      columnGroups: widget.columnGroups,
      mode: widget.mode,
      onChangedEventCallback: widget.onChanged,
      onSelectedEventCallback: widget.onSelected,
      onRowCheckedEventCallback: widget.onRowChecked,
      onRowDoubleTapEventCallback: widget.onRowDoubleTap,
      onRowSecondaryTapEventCallback: widget.onRowSecondaryTap,
      onRowsMovedEventCallback: widget.onRowsMoved,
      onRowColorCallback: widget.rowColorCallback,
      createHeader: widget.createHeader,
      createFooter: widget.createFooter,
      configuration: widget.configuration,
    );

    _stateManager.addListener(_changeStateListener);

    // Dispose
    _disposeList.add(() {
      _stateManager.removeListener(_changeStateListener);
      _stateManager.dispose();
    });
  }

  void _initKeyManager() {
    _keyManager = PlutoGridKeyManager(
      stateManager: _stateManager,
    );

    _keyManager.init();

    _stateManager.setKeyManager(_keyManager);

    // Dispose
    _disposeList.add(() {
      _keyManager.dispose();
    });
  }

  void _initEventManager() {
    _eventManager = PlutoGridEventManager(
      stateManager: _stateManager,
    );

    _eventManager.init();

    _stateManager.setEventManager(_eventManager);

    // Dispose
    _disposeList.add(() {
      _eventManager.dispose();
    });
  }

  void _initOnLoadedEvent() {
    if (widget.onLoaded == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onLoaded!(PlutoGridOnLoadedEvent(
        stateManager: _stateManager,
      ));
    });
  }

  void _initSelectMode() {
    if (widget.mode.isSelect != true) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_stateManager.currentCell == null && widget.rows.isNotEmpty) {
        _stateManager.setCurrentCell(
            widget.rows.first.cells.entries.first.value, 0);
      }

      _stateManager.gridFocusNode!.requestFocus();
    });
  }

  void _initHeaderFooter() {
    if (_stateManager.showHeader) {
      _header = _stateManager.createHeader!(_stateManager);
    }

    if (_stateManager.showFooter) {
      _footer = _stateManager.createFooter!(_stateManager);
    }

    if (_header is PlutoPagination || _footer is PlutoPagination) {
      _stateManager.setPage(1, notify: false);
    }
  }

  void _changeStateListener() {
    if (_showFrozenColumn != _stateManager.showFrozenColumn ||
        _hasLeftFrozenColumns != _stateManager.hasLeftFrozenColumns ||
        _bodyLeftOffset != _stateManager.bodyLeftOffset ||
        _bodyRightOffset != _stateManager.bodyRightOffset ||
        _hasRightFrozenColumns != _stateManager.hasRightFrozenColumns ||
        _rightFrozenLeftOffset != _stateManager.rightFrozenLeftOffset ||
        _showColumnGroups != _stateManager.showColumnGroups ||
        _showColumnFilter != _stateManager.showColumnFilter ||
        _showLoading != _stateManager.showLoading) {
      // it has been layout
      if (_stateManager.maxWidth != null) {
        setState(_resetState);
      }
    }
  }

  KeyEventResult _handleGridFocusOnKey(FocusNode focusNode, RawKeyEvent event) {
    /// 2021-11-19
    /// KeyEventResult.skipRemainingHandlers 동작 오류로 인한 임시 코드
    /// 이슈 해결 후 :
    /// ```dart
    /// keyManager!.subject.add(PlutoKeyManagerEvent(
    ///   focusNode: focusNode,
    ///   event: event,
    /// ));
    /// ```
    if (_keyManager.eventResult.isSkip == false) {
      _keyManager.subject.add(PlutoKeyManagerEvent(
        focusNode: focusNode,
        event: event,
      ));
    }

    /// 2021-11-19
    /// KeyEventResult.skipRemainingHandlers 동작 오류로 인한 임시 코드
    /// 이슈 해결 후 :
    /// ```dart
    /// return KeyEventResult.handled;
    /// ```
    return _keyManager.eventResult.consume(KeyEventResult.handled);
  }

  void _resetState() {
    _showFrozenColumn = _stateManager.showFrozenColumn;

    _hasLeftFrozenColumns = _stateManager.hasLeftFrozenColumns;

    _hasRightFrozenColumns = _stateManager.hasRightFrozenColumns;

    _showColumnGroups = _stateManager.showColumnGroups;

    _showColumnFilter = _stateManager.showColumnFilter;

    _showLoading = _stateManager.showLoading;

    // it may be called before layout
    if (_stateManager.maxWidth != null) {
      _bodyLeftOffset = _stateManager.bodyLeftOffset;

      _bodyRightOffset = _stateManager.bodyRightOffset;

      _rightFrozenLeftOffset = _stateManager.rightFrozenLeftOffset;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _stateManager,
      child: FocusScope(
        onFocusChange: _stateManager.setKeepFocus,
        onKey: _handleGridFocusOnKey,
        child: SafeArea(
          child: _GridContainer(
            stateManager: _stateManager,
            child: CustomMultiChildLayout(
              key: _stateManager.gridKey,
              delegate: PlutoGridLayoutDelegate(_stateManager),
              children: [
                LayoutId(
                    id: _StackName.bodyColumns,
                    child: PlutoBodyColumns(_stateManager)),
                LayoutId(
                    id: _StackName.bodyRows,
                    child: PlutoBodyRows(_stateManager)),
                if (_stateManager.showFrozenColumn &&
                    _stateManager.hasLeftFrozenColumns)
                  LayoutId(
                      id: _StackName.leftFrozenColumns,
                      child: PlutoLeftFrozenColumns(_stateManager)),
                if (_stateManager.showFrozenColumn &&
                    _stateManager.hasLeftFrozenColumns)
                  LayoutId(
                      id: _StackName.leftFrozenRows,
                      child: PlutoLeftFrozenRows(_stateManager)),
                if (_stateManager.showFrozenColumn &&
                    _stateManager.hasRightFrozenColumns)
                  LayoutId(
                      id: _StackName.rightFrozenColumns,
                      child: PlutoRightFrozenColumns(_stateManager)),
                if (_stateManager.showFrozenColumn &&
                    _stateManager.hasRightFrozenColumns)
                  LayoutId(
                      id: _StackName.rightFrozenRows,
                      child: PlutoRightFrozenRows(_stateManager)),
                LayoutId(
                  id: _StackName.columnRowDivider,
                  child: PlutoShadowLine(
                    axis: Axis.horizontal,
                    color: _stateManager.configuration!.gridBorderColor,
                    shadow: _stateManager.configuration!.enableGridBorderShadow,
                  ),
                ),
                if (_stateManager.showHeader)
                  LayoutId(
                    id: _StackName.headerDivider,
                    child: PlutoShadowLine(
                      axis: Axis.horizontal,
                      color: _stateManager.configuration!.gridBorderColor,
                      shadow:
                          _stateManager.configuration!.enableGridBorderShadow,
                    ),
                  ),
                if (_stateManager.showFooter)
                  LayoutId(
                    id: _StackName.footerDivider,
                    child: PlutoShadowLine(
                      axis: Axis.horizontal,
                      color: _stateManager.configuration!.gridBorderColor,
                      reverse: true,
                      shadow:
                          _stateManager.configuration!.enableGridBorderShadow,
                    ),
                  ),
                if (_stateManager.showFrozenColumn &&
                    _stateManager.hasLeftFrozenColumns)
                  LayoutId(
                      id: _StackName.leftFrozenDivider,
                      child: PlutoShadowLine(
                        axis: Axis.vertical,
                        color: _stateManager.configuration!.gridBorderColor,
                        shadow:
                            _stateManager.configuration!.enableGridBorderShadow,
                      )),
                if (_stateManager.showFrozenColumn &&
                    _stateManager.hasRightFrozenColumns)
                  LayoutId(
                      id: _StackName.rightFrozenDivider,
                      child: PlutoShadowLine(
                        axis: Axis.vertical,
                        color: _stateManager.configuration!.gridBorderColor,
                        reverse: true,
                        shadow:
                            _stateManager.configuration!.enableGridBorderShadow,
                      )),
                if (_stateManager.showHeader)
                  LayoutId(
                    id: _StackName.header,
                    child: _header!,
                  ),
                if (_stateManager.showFooter)
                  LayoutId(
                    id: _StackName.footer,
                    child: _footer!,
                  ),
                if (_stateManager.showLoading)
                  LayoutId(
                    id: _StackName.loading,
                    child: PlutoLoading(
                      backgroundColor:
                          _stateManager.configuration!.gridBackgroundColor,
                      indicatorColor:
                          _stateManager.configuration!.activatedBorderColor,
                      text: _stateManager.configuration!.localeText.loadingText,
                      textStyle: _stateManager.configuration!.cellTextStyle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlutoGridLayoutDelegate extends MultiChildLayoutDelegate {
  final PlutoGridStateManager _stateManager;

  PlutoGridLayoutDelegate(this._stateManager)
      : super(relayout: _stateManager.resizingChangeNotifier);

  @override
  void performLayout(Size size) {
    if (_stateManager.showFrozenColumn !=
        _stateManager.shouldShowFrozenColumns(size.width)) {
      _stateManager.notifyListenersOnPostFrame();
    }

    _stateManager.setLayout(BoxConstraints.tight(size));

    double bodyRowsTopOffset = 0;
    double bodyRowsBottomOffset = 0;
    double columnsTopOffset = 0;
    double bodyLeftOffset = 0;
    double bodyRightOffset = 0;

    // first layout header and footer and see what remains for the scrolling part
    if (hasChild(_StackName.header)) {
      // maximum 40% of the height
      var s = layoutChild(_StackName.header,
          BoxConstraints.loose(Size(size.width, size.height / 100 * 40)));

      _stateManager.headerHeight = s.height;

      bodyRowsTopOffset += s.height;

      columnsTopOffset += s.height;
    }

    if (hasChild(_StackName.headerDivider)) {
      layoutChild(
        _StackName.headerDivider,
        BoxConstraints.tight(
          Size(size.width, PlutoGridSettings.gridBorderWidth),
        ),
      );

      positionChild(
        _StackName.headerDivider,
        Offset(0, columnsTopOffset),
      );
    }

    if (hasChild(_StackName.footer)) {
      // maximum 40% of the height
      var s = layoutChild(_StackName.footer, BoxConstraints.loose(size));

      _stateManager.footerHeight = s.height;

      bodyRowsBottomOffset += s.height;

      positionChild(
        _StackName.footer,
        Offset(0, size.height - bodyRowsBottomOffset),
      );
    }

    if (hasChild(_StackName.footerDivider)) {
      layoutChild(
        _StackName.footerDivider,
        BoxConstraints.tight(
          Size(size.width, PlutoGridSettings.gridBorderWidth),
        ),
      );

      positionChild(
        _StackName.footerDivider,
        Offset(0, size.height - bodyRowsBottomOffset),
      );
    }

    // now layout columns of frozen sides and see what remains for the body width
    if (hasChild(_StackName.leftFrozenColumns)) {
      var s = layoutChild(
        _StackName.leftFrozenColumns,
        BoxConstraints.loose(size),
      );

      positionChild(
        _StackName.leftFrozenColumns,
        Offset(0, columnsTopOffset),
      );

      bodyLeftOffset = s.width;
    }

    if (hasChild(_StackName.leftFrozenDivider)) {
      var s = layoutChild(
        _StackName.leftFrozenDivider,
        BoxConstraints.tight(
          Size(
            PlutoGridSettings.gridBorderWidth,
            size.height - columnsTopOffset - bodyRowsBottomOffset,
          ),
        ),
      );

      positionChild(
        _StackName.leftFrozenDivider,
        Offset(bodyLeftOffset, columnsTopOffset),
      );

      bodyLeftOffset += s.width;
    }

    if (hasChild(_StackName.rightFrozenColumns)) {
      var s = layoutChild(
        _StackName.rightFrozenColumns,
        BoxConstraints.loose(size),
      );

      positionChild(
        _StackName.rightFrozenColumns,
        Offset(
          size.width - s.width + PlutoGridSettings.gridBorderWidth,
          columnsTopOffset,
        ),
      );

      bodyRightOffset = s.width;
    }

    if (hasChild(_StackName.rightFrozenDivider)) {
      var s = layoutChild(
        _StackName.rightFrozenDivider,
        BoxConstraints.tight(
          Size(
            PlutoGridSettings.gridBorderWidth,
            size.height - columnsTopOffset - bodyRowsBottomOffset,
          ),
        ),
      );

      positionChild(
        _StackName.rightFrozenDivider,
        Offset(
          size.width - bodyRightOffset - PlutoGridSettings.gridBorderWidth,
          columnsTopOffset,
        ),
      );

      bodyRightOffset += s.width;
    }

    if (hasChild(_StackName.bodyColumns)) {
      var s = layoutChild(
        _StackName.bodyColumns,
        BoxConstraints.loose(
          Size(
            size.width - bodyLeftOffset - bodyRightOffset,
            size.height,
          ),
        ),
      );

      positionChild(
        _StackName.bodyColumns,
        Offset(bodyLeftOffset, columnsTopOffset),
      );

      bodyRowsTopOffset += s.height;
    }

    // layout rows
    if (hasChild(_StackName.columnRowDivider)) {
      var s = layoutChild(
        _StackName.columnRowDivider,
        BoxConstraints.tight(
          Size(
            size.width,
            PlutoGridSettings.gridBorderWidth,
          ),
        ),
      );

      positionChild(
        _StackName.columnRowDivider,
        Offset(0, bodyRowsTopOffset),
      );

      bodyRowsTopOffset += s.height;
    }

    if (hasChild(_StackName.leftFrozenRows)) {
      layoutChild(
        _StackName.leftFrozenRows,
        BoxConstraints.loose(
          Size(
            bodyLeftOffset,
            size.height - bodyRowsTopOffset - bodyRowsBottomOffset,
          ),
        ),
      );

      positionChild(
        _StackName.leftFrozenRows,
        Offset(0, bodyRowsTopOffset),
      );
    }

    if (hasChild(_StackName.rightFrozenRows)) {
      layoutChild(
        _StackName.rightFrozenRows,
        BoxConstraints.loose(
          Size(
            bodyRightOffset,
            size.height - bodyRowsTopOffset - bodyRowsBottomOffset,
          ),
        ),
      );

      positionChild(
        _StackName.rightFrozenRows,
        Offset(
          size.width - bodyRightOffset + PlutoGridSettings.gridBorderWidth,
          bodyRowsTopOffset,
        ),
      );
    }

    if (hasChild(_StackName.bodyRows)) {
      var height = size.height - bodyRowsTopOffset - bodyRowsBottomOffset;

      var width = size.width - bodyLeftOffset - bodyRightOffset;

      layoutChild(
        _StackName.bodyRows,
        BoxConstraints.tight(Size(width, height)),
      );

      positionChild(
        _StackName.bodyRows,
        Offset(bodyLeftOffset, bodyRowsTopOffset),
      );
    }

    if (hasChild(_StackName.loading)) {
      layoutChild(
        _StackName.loading,
        BoxConstraints.tight(size),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}

class _GridContainer extends StatelessWidget {
  final PlutoGridStateManager stateManager;

  final Widget child;

  const _GridContainer({
    required this.stateManager,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final configuration = stateManager.configuration!;

    return Focus(
      focusNode: stateManager.gridFocusNode,
      child: ScrollConfiguration(
        behavior: const PlutoScrollBehavior().copyWith(
          scrollbars: false,
        ),
        child: Container(
          padding: const EdgeInsets.all(PlutoGridSettings.gridPadding),
          decoration: BoxDecoration(
            color: configuration.gridBackgroundColor,
            borderRadius: configuration.gridBorderRadius,
            border: Border.all(
              color: configuration.gridBorderColor,
              width: PlutoGridSettings.gridBorderWidth,
            ),
          ),
          child: ClipRRect(
            borderRadius:
                configuration.gridBorderRadius.resolve(TextDirection.ltr),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PlutoGridOnLoadedEvent {
  final PlutoGridStateManager stateManager;

  const PlutoGridOnLoadedEvent({
    required this.stateManager,
  });
}

/// Caution
///
/// [columnIdx] and [rowIdx] are values in the currently displayed state.
class PlutoGridOnChangedEvent {
  final int? columnIdx;
  final PlutoColumn? column;
  final int? rowIdx;
  final PlutoRow? row;
  final dynamic value;
  final dynamic oldValue;

  PlutoGridOnChangedEvent({
    this.columnIdx,
    this.column,
    this.rowIdx,
    this.row,
    this.value,
    this.oldValue,
  });

  @override
  String toString() {
    String out = '[PlutoOnChangedEvent] ';
    out += 'ColumnIndex : $columnIdx, RowIndex : $rowIdx\n';
    out += '::: oldValue : $oldValue\n';
    out += '::: newValue : $value';
    return out;
  }
}

class PlutoGridOnSelectedEvent {
  final PlutoRow? row;
  final int? rowIdx;
  final PlutoCell? cell;

  PlutoGridOnSelectedEvent({
    this.row,
    this.rowIdx,
    this.cell,
  });
}

abstract class PlutoGridOnRowCheckedEvent {
  bool get isAll => runtimeType == PlutoGridOnRowCheckedAllEvent;

  bool get isRow => runtimeType == PlutoGridOnRowCheckedOneEvent;

  final PlutoRow? row;
  final int? rowIdx;
  final bool? isChecked;

  PlutoGridOnRowCheckedEvent({
    this.row,
    this.rowIdx,
    this.isChecked,
  });
}

class PlutoGridOnRowDoubleTapEvent {
  final PlutoRow? row;
  final int? rowIdx;
  final PlutoCell? cell;

  PlutoGridOnRowDoubleTapEvent({
    this.row,
    this.rowIdx,
    this.cell,
  });
}

class PlutoGridOnRowSecondaryTapEvent {
  final PlutoRow? row;
  final int? rowIdx;
  final PlutoCell? cell;
  final Offset? offset;

  PlutoGridOnRowSecondaryTapEvent({
    this.row,
    this.rowIdx,
    this.cell,
    this.offset,
  });
}

class PlutoGridOnRowsMovedEvent {
  final int? idx;
  final List<PlutoRow?>? rows;

  PlutoGridOnRowsMovedEvent({
    required this.idx,
    required this.rows,
  });
}

class PlutoGridOnRowCheckedOneEvent extends PlutoGridOnRowCheckedEvent {
  PlutoGridOnRowCheckedOneEvent({
    PlutoRow? row,
    int? rowIdx,
    bool? isChecked,
  }) : super(row: row, rowIdx: rowIdx, isChecked: isChecked);
}

class PlutoGridOnRowCheckedAllEvent extends PlutoGridOnRowCheckedEvent {
  PlutoGridOnRowCheckedAllEvent({
    bool? isChecked,
  }) : super(row: null, rowIdx: null, isChecked: isChecked);
}

class PlutoScrollBehavior extends MaterialScrollBehavior {
  const PlutoScrollBehavior() : super();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class PlutoRowColorContext {
  final PlutoRow row;

  final int rowIdx;

  final PlutoGridStateManager stateManager;

  PlutoRowColorContext({
    required this.row,
    required this.rowIdx,
    required this.stateManager,
  });
}

enum PlutoGridMode {
  normal,
  select,
  selectWithOneTap,
  popup,
}

extension PlutoGridModeExtension on PlutoGridMode? {
  bool get isNormal => this == PlutoGridMode.normal;

  bool get isSelect =>
      this == PlutoGridMode.select || this == PlutoGridMode.selectWithOneTap;

  bool get isSelectModeWithOneTap => this == PlutoGridMode.selectWithOneTap;

  bool get isPopup => this == PlutoGridMode.popup;
}

enum _StackName {
  header,
  headerDivider,
  leftFrozenColumns,
  leftFrozenRows,
  leftFrozenDivider,
  bodyColumns,
  bodyRows,
  rightFrozenColumns,
  rightFrozenRows,
  rightFrozenDivider,
  columnRowDivider,
  footer,
  footerDivider,
  loading,
}

class PlutoGridSettings {
  /// If there is a frozen column, the minimum width of the body
  /// (if it is less than the value, the frozen column is released)
  static const double bodyMinWidth = 200.0;

  /// Default column width
  static const double columnWidth = 200.0;

  /// Column width
  static const double minColumnWidth = 80.0;

  /// Frozen column division line (ShadowLine) size
  static const double shadowLineSize = 3.0;

  /// Sum of frozen column division line width
  static const double totalShadowLineWidth =
      PlutoGridSettings.shadowLineSize * 2;

  /// Grid - padding
  static const double gridPadding = 2.0;

  /// Grid - border width
  static const double gridBorderWidth = 1.0;

  static const double gridInnerSpacing =
      (gridPadding * 2) + (gridBorderWidth * 2);

  /// Row - Default row height
  static const double rowHeight = 45.0;

  /// Row - border width
  static const double rowBorderWidth = 1.0;

  /// Row - total height
  static const double rowTotalHeight = rowHeight + rowBorderWidth;

  /// Cell - padding
  static const double cellPadding = 10;

  /// Column title - padding
  static const double columnTitlePadding = 10;

  /// Cell - fontSize
  static const double cellFontSize = 14;

  /// Scroll when multi-selection is as close as that value from the edge
  static const double offsetScrollingFromEdge = 10.0;

  /// Size that scrolls from the edge at once when selecting multiple
  static const double offsetScrollingFromEdgeAtOnce = 200.0;

  static const int debounceMillisecondsForColumnFilter = 300;
}

typedef PlutoOnLoadedEventCallback = void Function(
    PlutoGridOnLoadedEvent event);

typedef PlutoOnChangedEventCallback = void Function(
    PlutoGridOnChangedEvent event);

typedef PlutoOnSelectedEventCallback = void Function(
    PlutoGridOnSelectedEvent event);

typedef PlutoOnRowCheckedEventCallback = void Function(
    PlutoGridOnRowCheckedEvent event);

typedef PlutoOnRowDoubleTapEventCallback = void Function(
    PlutoGridOnRowDoubleTapEvent event);

typedef PlutoOnRowSecondaryTapEventCallback = void Function(
    PlutoGridOnRowSecondaryTapEvent event);

typedef PlutoOnRowsMovedEventCallback = void Function(
    PlutoGridOnRowsMovedEvent event);

typedef CreateHeaderCallBack = Widget Function(
    PlutoGridStateManager stateManager);

typedef CreateFooterCallBack = Widget Function(
    PlutoGridStateManager stateManager);

typedef PlutoRowColorCallback = Color Function(
    PlutoRowColorContext rowColorContext);
