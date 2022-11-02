import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../ui/ui.dart';

/// {@template pluto_aggregate_filter}
/// Returns whether to be filtered according to the value of [PlutoCell.value].
/// {@endtemplate}
typedef PlutoAggregateFilter = bool Function(PlutoCell);

/// {@template pluto_aggregate_column_type}
/// Determine the aggregate type.
///
/// [sum] Returns the sum of all values.
///
/// [average] Returns the result of adding up all values and dividing by the number of elements.
///
/// [min] Returns the smallest value among all values.
///
/// [max] Returns the largest value out of all values.
///
/// [count] Returns the total count.
/// {@endtemplate}
enum PlutoAggregateColumnType {
  sum,
  average,
  min,
  max,
  count,
}

/// {@template pluto_aggregate_column_grouped_row_type}
/// When grouping row is applied, set the condition of row to be aggregated.
///
/// [all] processes both groups and rows.
///
/// [expandedAll] processes only the group and the children of the expanded group.
///
/// [rows] processes non-group rows.
///
/// [expandedRows] processes only expanded rows, not groups.
/// {@endtemplate}
enum PlutoAggregateColumnGroupedRowType {
  all,
  expandedAll,
  rows,
  expandedRows;

  bool get isAll => this == PlutoAggregateColumnGroupedRowType.all;

  bool get isExpandedAll =>
      this == PlutoAggregateColumnGroupedRowType.expandedAll;

  bool get isRows => this == PlutoAggregateColumnGroupedRowType.rows;

  bool get isExpandedRows =>
      this == PlutoAggregateColumnGroupedRowType.expandedRows;

  bool get isExpanded => isExpandedAll || isExpandedRows;

  bool get isRowsOnly => isRows || isExpandedRows;
}

/// Widget for outputting the sum, average, minimum,
/// and maximum values of all values in a column.
///
/// Example) [PlutoColumn.footerRenderer] Implement column footer as return value of callback
/// ```dart
/// PlutoColumn(
///   title: 'column',
///   field: 'column',
///   type: PlutoColumnType.number(format: '#,###.###'),
///   textAlign: PlutoColumnTextAlign.right,
///   footerRenderer: (rendererContext) {
///     return PlutoAggregateColumnFooter(
///       rendererContext: rendererContext,
///       type: PlutoAggregateColumnType.sum,
///       format: 'Sum : #,###.###',
///       alignment: Alignment.center,
///     );
///   },
/// ),
/// ```
///
/// [PlutoAggregateColumnFooter]
/// You can also return a [Widget] you wrote yourself instead of a widget.
/// However, you must implement the process
/// of updating according to the value change yourself.
class PlutoAggregateColumnFooter extends PlutoStatefulWidget {
  /// Contains information needed to implement the widget.
  final PlutoColumnFooterRendererContext rendererContext;

  /// {@macro pluto_aggregate_column_type}
  final PlutoAggregateColumnType type;

  /// {@macro pluto_aggregate_column_grouped_row_type}
  final PlutoAggregateColumnGroupedRowType groupedRowType;

  /// {@macro pluto_aggregate_filter}
  ///
  /// Example) Only when the value of [PlutoCell.value] is Android,
  /// it is included in the aggregate list.
  /// ```dart
  /// filter: (cell) => cell.value == 'Android',
  /// ```
  final PlutoAggregateFilter? filter;

  /// Set the format of aggregated result values.
  ///
  /// Example)
  /// ```dart
  /// format: 'Android: #,###', // Android: 100 (if the result is 100)
  /// format: '#,###.###', // 1,000,000.123 (expressed to 3 decimal places)
  /// ```
  final String format;

  /// Setting the locale of the resulting value.
  ///
  /// Example)
  /// ```dart
  /// locale: 'da_DK',
  /// ```
  final String? locale;

  /// You can customize the resulting values.
  ///
  /// Example)
  /// ```dart
  /// titleSpanBuilder: (text) {
  ///   return [
  ///     const TextSpan(
  ///       text: 'Sum',
  ///       style: TextStyle(color: Colors.red),
  ///     ),
  ///     const TextSpan(text: ' : '),
  ///     TextSpan(text: text),
  ///   ];
  /// },
  /// ```
  final List<InlineSpan> Function(String)? titleSpanBuilder;

  final AlignmentGeometry? alignment;

  final EdgeInsets? padding;

  final bool formatAsCurrency;

  const PlutoAggregateColumnFooter({
    required this.rendererContext,
    required this.type,
    this.groupedRowType = PlutoAggregateColumnGroupedRowType.all,
    this.filter,
    this.format = '#,###',
    this.locale,
    this.titleSpanBuilder,
    this.alignment,
    this.padding,
    this.formatAsCurrency = false,
    super.key,
  });

  @override
  PlutoAggregateColumnFooterState createState() =>
      PlutoAggregateColumnFooterState();
}

class PlutoAggregateColumnFooterState
    extends PlutoStateWithChange<PlutoAggregateColumnFooter> {
  @override
  PlutoGridStateManager get stateManager => widget.rendererContext.stateManager;

  PlutoColumn get column => widget.rendererContext.column;

  num? _aggregatedValue;

  late final NumberFormat _numberFormat;

  late final num? Function({
    required Iterable<PlutoRow> rows,
    required PlutoColumn column,
    PlutoAggregateFilter? filter,
  }) _aggregator;

  Iterable<PlutoRow> get rows {
    if (!stateManager.enabledRowGroups) return stateManager.refRows;

    bool Function(PlutoRow)? filter;
    Iterator<PlutoRow>? Function(PlutoRow)? childrenFilter;

    if (widget.groupedRowType.isRowsOnly) {
      filter = (r) => !r.type.isGroup;
    }

    if (widget.groupedRowType.isExpanded) {
      childrenFilter = (r) => r.type.isGroup && r.type.group.expanded
          ? r.type.group.children.iterator
          : null;
    }

    return PlutoRowGroupHelper.iterateWithFilter(
      stateManager.iterateMainRowGroup,
      iterateAll: false,
      filter: filter,
      childrenFilter: childrenFilter,
    );
  }

  @override
  void initState() {
    super.initState();

    _numberFormat = widget.formatAsCurrency
        ? NumberFormat.simpleCurrency(locale: widget.locale)
        : NumberFormat(widget.format, widget.locale);

    _setAggregator();

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    _aggregatedValue = update<num?>(
      _aggregatedValue,
      _aggregator(
        rows: rows,
        column: column,
        filter: widget.filter,
      ),
    );
  }

  void _setAggregator() {
    switch (widget.type) {
      case PlutoAggregateColumnType.sum:
        _aggregator = PlutoAggregateHelper.sum;
        break;
      case PlutoAggregateColumnType.average:
        _aggregator = PlutoAggregateHelper.average;
        break;
      case PlutoAggregateColumnType.min:
        _aggregator = PlutoAggregateHelper.min;
        break;
      case PlutoAggregateColumnType.max:
        _aggregator = PlutoAggregateHelper.max;
        break;
      case PlutoAggregateColumnType.count:
        _aggregator = PlutoAggregateHelper.count;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTitleSpan = widget.titleSpanBuilder != null;

    final formattedValue =
        _aggregatedValue == null ? '' : _numberFormat.format(_aggregatedValue);

    final text = hasTitleSpan ? null : formattedValue;

    final children =
        hasTitleSpan ? widget.titleSpanBuilder!(formattedValue) : null;

    return Padding(
      padding: widget.padding ?? PlutoGridSettings.columnTitlePadding,
      child: Align(
        alignment: widget.alignment ?? AlignmentDirectional.centerStart,
        child: Text.rich(
          TextSpan(text: text, children: children),
          style: stateManager.configuration.style.cellTextStyle.copyWith(
            decoration: TextDecoration.none,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
