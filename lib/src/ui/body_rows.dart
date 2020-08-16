part of pluto_grid;

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

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    _columns = getColumns();

    _rows = widget.stateManager.rows;

    _width = getWidth();

    widget.stateManager.addListener(changeStateListener);

    super.initState();
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
    return widget.stateManager.layout.showFixedColumn == true
        ? widget.stateManager.bodyColumns
        : widget.stateManager.columns;
  }

  double getWidth() {
    return widget.stateManager.layout.showFixedColumn == true
        ? widget.stateManager.bodyColumnsWidth
        : widget.stateManager.columnsWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        controller: widget.stateManager.scroll.bodyRowsHorizontal,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _width,
          child: ListView.builder(
            controller: widget.stateManager.scroll.bodyRowsVertical,
            scrollDirection: Axis.vertical,
            itemCount: _rows.length,
            itemBuilder: (ctx, i) {
              return RowWidget(
                key: ValueKey('bodyRow_${_rows[i]._key}'),
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
