part of '../../pluto_grid.dart';

class PlutoBodyRows extends StatefulWidget {
  final PlutoStateManager stateManager;

  PlutoBodyRows(this.stateManager);

  @override
  _PlutoBodyRowsState createState() => _PlutoBodyRowsState();
}

class _PlutoBodyRowsState extends State<PlutoBodyRows> {
  List<PlutoColumn> _columns;

  List<PlutoRow> _rows;

  double _width;

  ScrollController verticalScroll;

  ScrollController horizontalScroll;

  @override
  void dispose() {
    verticalScroll.dispose();

    horizontalScroll.dispose();

    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _columns = getColumns();

    _rows = widget.stateManager.rows;

    _width = getWidth();

    horizontalScroll = widget.stateManager.scroll.horizontal.addAndGet();

    widget.stateManager.scroll.setBodyRowsHorizontal(horizontalScroll);

    verticalScroll = widget.stateManager.scroll.vertical.addAndGet();

    widget.stateManager.scroll.setBodyRowsVertical(verticalScroll);

    widget.stateManager.addListener(changeStateListener);
  }

  void changeStateListener() {
    if (listEquals(_columns, getColumns()) == false ||
        listEquals(_rows, widget.stateManager._rows) == false ||
        _width != getWidth()) {
      setState(() {
        _columns = getColumns();
        _rows = widget.stateManager.rows;
        _width = getWidth();
      });
    }
  }

  List<PlutoColumn> getColumns() {
    return widget.stateManager.showFrozenColumn == true
        ? widget.stateManager.bodyColumns
        : widget.stateManager.columns;
  }

  double getWidth() {
    return widget.stateManager.showFrozenColumn == true
        ? widget.stateManager.bodyColumnsWidth
        : widget.stateManager.columnsWidth;
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
          width: _width,
          child: ListView.builder(
            controller: verticalScroll,
            scrollDirection: Axis.vertical,
            itemCount: _rows.length,
            itemExtent: widget.stateManager.rowTotalHeight,
            itemBuilder: (ctx, i) {
              return PlutoBaseRow(
                key: ValueKey('body_row_${_rows[i]._key}'),
                stateManager: widget.stateManager,
                rowIdx: i,
                row: _rows[i],
                columns: _columns,
              );
            },
          ),
        ),
      ),
    );
  }
}
