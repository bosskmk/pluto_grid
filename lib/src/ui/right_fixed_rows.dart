part of '../../pluto_grid.dart';

class RightFixedRows extends StatefulWidget {
  final PlutoStateManager stateManager;

  RightFixedRows(this.stateManager);

  @override
  _RightFixedRowsState createState() => _RightFixedRowsState();
}

class _RightFixedRowsState extends State<RightFixedRows> {
  List<PlutoColumn> _columns;

  List<PlutoRow> _rows;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    _columns = widget.stateManager.rightFixedColumns;

    _rows = widget.stateManager.rows;

    widget.stateManager.addListener(changeStateListener);

    super.initState();
  }

  void changeStateListener() {
    if (listEquals(_columns, widget.stateManager.rightFixedColumns) == false ||
        listEquals(_rows, widget.stateManager.rows) == false) {
      setState(() {
        _columns = widget.stateManager.rightFixedColumns;
        _rows = widget.stateManager.rows;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.stateManager.scroll.rightRowsVerticalScroll,
      scrollDirection: Axis.vertical,
      itemCount: _rows.length,
      itemBuilder: (ctx, i) {
        return RowWidget(
          key: ValueKey('right_fixed_row_${_rows[i]._key}'),
          stateManager: widget.stateManager,
          rowIdx: i,
          row: _rows[i],
          columns: _columns,
        );
      },
    );
  }
}
