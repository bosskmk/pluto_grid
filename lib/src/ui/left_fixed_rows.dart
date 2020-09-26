part of '../../pluto_grid.dart';

class LeftFixedRows extends StatefulWidget {
  final PlutoStateManager stateManager;

  LeftFixedRows(this.stateManager);

  @override
  _LeftFixedRowsState createState() => _LeftFixedRowsState();
}

class _LeftFixedRowsState extends State<LeftFixedRows> {
  List<PlutoColumn> _columns;

  List<PlutoRow> _rows;

  ScrollController scroll;

  @override
  void dispose() {
    scroll.dispose();

    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _columns = widget.stateManager.leftFixedColumns;

    _rows = widget.stateManager.rows;

    scroll = widget.stateManager.scroll.vertical.addAndGet();

    widget.stateManager.addListener(changeStateListener);
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
      controller: scroll,
      scrollDirection: Axis.vertical,
      itemCount: _rows.length,
      itemExtent: PlutoDefaultSettings.rowTotalHeight,
      itemBuilder: (ctx, i) {
        return RowWidget(
          key: ValueKey('left_fixed_row_${_rows[i]._key}'),
          stateManager: widget.stateManager,
          rowIdx: i,
          row: _rows[i],
          columns: _columns,
        );
      },
    );
  }
}
