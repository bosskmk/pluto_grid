part of '../../pluto_grid.dart';

class PlutoBodyRows extends _PlutoStatefulWidget {
  final PlutoStateManager stateManager;

  PlutoBodyRows(this.stateManager);

  @override
  _PlutoBodyRowsState createState() => _PlutoBodyRowsState();
}

abstract class _PlutoBodyRowsStateWithChange
    extends _PlutoStateWithChange<PlutoBodyRows> {
  List<PlutoColumn> columns;

  List<PlutoRow> rows;

  double width;

  @override
  void onChange() {
    resetState((update) {
      columns = update<List<PlutoColumn>>(
        columns,
        _getColumns(),
        compare: listEquals,
      );

      rows = update<List<PlutoRow>>(
        rows,
        widget.stateManager._rows,
        compare: listEquals,
        destructureList: true,
      );

      width = update<double>(width, _getWidth());
    });
  }

  List<PlutoColumn> _getColumns() {
    return widget.stateManager.showFrozenColumn == true
        ? widget.stateManager.bodyColumns
        : widget.stateManager.columns;
  }

  double _getWidth() {
    return widget.stateManager.showFrozenColumn == true
        ? widget.stateManager.bodyColumnsWidth
        : widget.stateManager.columnsWidth;
  }
}

class _PlutoBodyRowsState extends _PlutoBodyRowsStateWithChange {
  ScrollController verticalScroll;

  ScrollController horizontalScroll;

  @override
  void dispose() {
    verticalScroll.dispose();

    horizontalScroll.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    horizontalScroll = widget.stateManager.scroll.horizontal.addAndGet();

    widget.stateManager.scroll.setBodyRowsHorizontal(horizontalScroll);

    verticalScroll = widget.stateManager.scroll.vertical.addAndGet();

    widget.stateManager.scroll.setBodyRowsVertical(verticalScroll);
  }

  @override
  Widget build(BuildContext context) {
    return PlutoScrollbar(
      verticalController:
          widget.stateManager.configuration.scrollbarConfig.draggableScrollbar
              ? verticalScroll
              : null,
      horizontalController:
          widget.stateManager.configuration.scrollbarConfig.draggableScrollbar
              ? horizontalScroll
              : null,
      isAlwaysShown:
          widget.stateManager.configuration.scrollbarConfig.isAlwaysShown,
      thickness:
          widget.stateManager.configuration.scrollbarConfig.scrollbarThickness,
      thicknessWhileDragging: widget.stateManager.configuration.scrollbarConfig
          .scrollbarThicknessWhileDragging,
      radius: widget.stateManager.configuration.scrollbarConfig.scrollbarRadius,
      radiusWhileDragging: widget.stateManager.configuration.scrollbarConfig
          .scrollbarRadiusWhileDragging,
      child: SingleChildScrollView(
        controller: horizontalScroll,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: width,
          child: ListView.builder(
            controller: verticalScroll,
            scrollDirection: Axis.vertical,
            itemCount: rows.length,
            itemExtent: widget.stateManager.rowTotalHeight,
            itemBuilder: (ctx, i) {
              return PlutoBaseRow(
                key: ValueKey('body_row_${rows[i]._key}'),
                stateManager: widget.stateManager,
                rowIdx: i,
                row: rows[i],
                columns: columns,
              );
            },
          ),
        ),
      ),
    );
  }
}
