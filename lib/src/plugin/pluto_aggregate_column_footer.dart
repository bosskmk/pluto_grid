import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../ui/ui.dart';

typedef PlutoAggregateFilter = bool Function(PlutoCell);

enum PlutoAggregateColumnType {
  sum,
  average,
  min,
  max,
  count,
}

class PlutoAggregateColumnFooter extends PlutoStatefulWidget {
  final PlutoColumnFooterRendererContext rendererContext;

  final PlutoAggregateColumnType type;

  final PlutoAggregateFilter? filter;

  final String format;

  final String? locale;

  final List<InlineSpan> Function(String)? titleSpanBuilder;

  final AlignmentGeometry? alignment;

  final EdgeInsets? padding;

  const PlutoAggregateColumnFooter({
    required this.rendererContext,
    required this.type,
    this.filter,
    this.format = '#,###',
    this.locale,
    this.titleSpanBuilder,
    this.alignment,
    this.padding,
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
    required List<PlutoRow> rows,
    required PlutoColumn column,
    PlutoAggregateFilter? filter,
  }) _aggregator;

  @override
  void initState() {
    super.initState();

    _numberFormat = NumberFormat(widget.format, widget.locale);

    _setAggregator();

    updateState();
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
  void updateState() {
    _aggregatedValue = update<num?>(
      _aggregatedValue,
      _aggregator(
        rows: stateManager.refRows,
        column: column,
        filter: widget.filter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasTitleSpan = widget.titleSpanBuilder != null;

    final formattedValue =
        _aggregatedValue == null ? '' : _numberFormat.format(_aggregatedValue);

    final text = hasTitleSpan ? null : formattedValue;

    final children =
        hasTitleSpan ? widget.titleSpanBuilder!(formattedValue) : null;

    return Container(
      padding: widget.padding ?? PlutoGridSettings.columnTitlePadding,
      alignment: widget.alignment ?? AlignmentDirectional.centerStart,
      child: Text.rich(
        TextSpan(
          text: text,
          children: children,
        ),
        style: stateManager.configuration!.style.cellTextStyle.copyWith(
          decoration: TextDecoration.none,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
