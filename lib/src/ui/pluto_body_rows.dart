import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBodyRows extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  const PlutoBodyRows(
    this.stateManager, {
    Key? key,
  }) : super(key: key);

  @override
  PlutoBodyRowsState createState() => PlutoBodyRowsState();
}

abstract class _PlutoBodyRowsStateWithChange
    extends PlutoStateWithChange<PlutoBodyRows> {
  List<PlutoColumn>? _columns;

  List<PlutoRow?>? _rows;

  @override
  bool allowStream(event) {
    return event is! PlutoSetCurrentCellStreamNotifierEvent;
  }

  @override
  void onChange(event) {
    resetState((update) {
      _columns = update<List<PlutoColumn>?>(
        _columns,
        _getColumns(),
        compare: listEquals,
      );

      _rows = [
        ...update<List<PlutoRow?>?>(
          _rows,
          widget.stateManager.refRows,
          compare: listEquals,
        )!
      ];
    });
  }

  List<PlutoColumn> _getColumns() {
    return widget.stateManager.showFrozenColumn == true
        ? widget.stateManager.bodyColumns
        : widget.stateManager.columns;
  }
}

class PlutoBodyRowsState extends _PlutoBodyRowsStateWithChange {
  ScrollController? _verticalScroll;

  ScrollController? _horizontalScroll;

  @override
  void dispose() {
    _verticalScroll!.dispose();

    _horizontalScroll!.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _horizontalScroll = widget.stateManager.scroll!.horizontal!.addAndGet();

    widget.stateManager.scroll!.setBodyRowsHorizontal(_horizontalScroll);

    _verticalScroll = widget.stateManager.scroll!.vertical!.addAndGet();

    widget.stateManager.scroll!.setBodyRowsVertical(_verticalScroll);
  }

  @override
  Widget build(BuildContext context) {
    return PlutoScrollbar(
      verticalController:
          widget.stateManager.configuration!.scrollbarConfig.draggableScrollbar
              ? _verticalScroll
              : null,
      horizontalController:
          widget.stateManager.configuration!.scrollbarConfig.draggableScrollbar
              ? _horizontalScroll
              : null,
      isAlwaysShown:
          widget.stateManager.configuration!.scrollbarConfig.isAlwaysShown,
      thickness:
          widget.stateManager.configuration!.scrollbarConfig.scrollbarThickness,
      thicknessWhileDragging: widget.stateManager.configuration!.scrollbarConfig
          .scrollbarThicknessWhileDragging,
      radius:
          widget.stateManager.configuration!.scrollbarConfig.scrollbarRadius,
      radiusWhileDragging: widget.stateManager.configuration!.scrollbarConfig
          .scrollbarRadiusWhileDragging,
      child: SingleChildScrollView(
        controller: _horizontalScroll,
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: CustomSingleChildLayout(
          delegate: ListResizeDelegate(widget.stateManager, _getColumns()),
          child: ListView.builder(
            controller: _verticalScroll,
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
            itemCount: _rows!.length,
            itemExtent: widget.stateManager.rowTotalHeight,
            itemBuilder: (ctx, i) {
              return PlutoBaseRow(
                key: ValueKey('body_row_${_rows![i]!.key}'),
                rowIdx: i,
                row: _rows![i]!,
                columns: _columns!,
              );
            },
          ),
        ),
      ),
    );
  }
}

class ListResizeDelegate extends SingleChildLayoutDelegate {
  PlutoGridStateManager stateManager;

  List<PlutoColumn> columns;

  ListResizeDelegate(this.stateManager, this.columns)
      : super(relayout: stateManager.resizingChangeNotifier);

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) {
    return true;
  }

  double _getWidth() {
    return columns.fold(
        0, (previousValue, element) => previousValue + element.width);
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return constraints.tighten(width: _getWidth()).biggest;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return const Offset(0, 0);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.tighten(width: _getWidth());
  }
}
