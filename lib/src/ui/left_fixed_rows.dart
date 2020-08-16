part of pluto_grid;

class LeftFixedRows extends StatefulWidget {
  final PlutoStateManager stateManager;

  LeftFixedRows(this.stateManager);

  @override
  _LeftFixedRowsState createState() => _LeftFixedRowsState();
}

class _LeftFixedRowsState extends State<LeftFixedRows> {
  List<PlutoColumn> _columns;

  List<PlutoRow> _rows;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    _columns = widget.stateManager.leftFixedColumns;

    _rows = widget.stateManager.rows;

    widget.stateManager.addListener(changeStateListener);

    super.initState();
  }

  void changeStateListener() {
    if (listEquals(_columns, widget.stateManager.leftFixedColumns) == false ||
        listEquals(_rows, widget.stateManager.rows) == false) {
      setState(() {
        _columns = widget.stateManager.leftFixedColumns;
        _rows = widget.stateManager.rows;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.stateManager.scroll.leftFixedRowsVertical,
      scrollDirection: Axis.vertical,
      itemCount: _rows.length,
      itemBuilder: (ctx, i) {
        return RowWidget(
          key: ValueKey('left_fixed_row_${_rows[i]._key.toString()}'),
          stateManager: widget.stateManager,
          row: _rows[i],
          columns: _columns,
        );
      },
    );
  }
}
