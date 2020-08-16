part of pluto_grid;

class LeftFixedRows extends StatefulWidget {
  final PlutoStateManager stateManager;

  LeftFixedRows(this.stateManager);

  @override
  _LeftFixedRowsState createState() => _LeftFixedRowsState();
}

class _LeftFixedRowsState extends State<LeftFixedRows> {
  List<int> _columnIndexes;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    _columnIndexes = widget.stateManager.leftFixedColumnIndexes;

    widget.stateManager.addListener(changeStateListener);

    super.initState();
  }

  void changeStateListener() {
    if (listEquals(
            _columnIndexes, widget.stateManager.leftFixedColumnIndexes) ==
        false) {
      setState(() {
        _columnIndexes = widget.stateManager.leftFixedColumnIndexes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.stateManager.scroll.leftFixedRowsVertical,
      scrollDirection: Axis.vertical,
      itemCount: widget.stateManager.rows.length,
      itemBuilder: (ctx, i) {
        return RowWidget(
          stateManager: widget.stateManager,
          row: widget.stateManager.rows[i],
          columnIndexes: _columnIndexes,
        );
      },
    );
  }
}
