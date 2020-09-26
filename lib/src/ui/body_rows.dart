part of '../../pluto_grid.dart';

class BodyRows extends StatefulWidget {
  final PlutoStateManager stateManager;

  BodyRows(this.stateManager);

  @override
  _BodyRowsState createState() => _BodyRowsState();
}

class _BodyRowsState extends State<BodyRows> {
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

    verticalScroll = widget.stateManager.scroll.vertical.addAndGet();

    horizontalScroll = widget.stateManager.scroll.horizontal.addAndGet();

    widget.stateManager.scroll.setBodyRowsVertical(verticalScroll);

    widget.stateManager.addListener(changeStateListener);
  }

  void changeStateListener() {
    if (listEquals(_columns, getColumns()) == false ||
        listEquals(_rows, widget.stateManager.rows) == false ||
        _width != getWidth()) {
      setState(() {
        _columns = getColumns();
        _rows = widget.stateManager.rows;
        _width = getWidth();
      });
    }
  }

  List<PlutoColumn> getColumns() {
    return widget.stateManager.showFixedColumn == true
        ? widget.stateManager.bodyColumns
        : widget.stateManager.columns;
  }

  double getWidth() {
    return widget.stateManager.showFixedColumn == true
        ? widget.stateManager.bodyColumnsWidth
        : widget.stateManager.columnsWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        controller: horizontalScroll,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _width,
          child: ListView.builder(
            controller: verticalScroll,
            scrollDirection: Axis.vertical,
            itemCount: _rows.length,
            itemExtent: PlutoDefaultSettings.rowTotalHeight,
            itemBuilder: (ctx, i) {
              return RowWidget(
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
