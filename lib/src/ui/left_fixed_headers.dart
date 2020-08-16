part of pluto_grid;

class LeftFixedHeaders extends StatefulWidget {
  final PlutoStateManager stateManager;

  LeftFixedHeaders(this.stateManager);

  @override
  _LeftFixedHeadersState createState() => _LeftFixedHeadersState();
}

class _LeftFixedHeadersState extends State<LeftFixedHeaders> {
  List<PlutoColumn> _columns;
  double _width;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);
    super.dispose();
  }

  @override
  void initState() {
    _columns = widget.stateManager.leftFixedColumns;
    _width = widget.stateManager.leftFixedColumnsWidth;

    widget.stateManager.addListener(changeStateListener);

    super.initState();
  }

  void changeStateListener() {
    if (listEquals(_columns, widget.stateManager.leftFixedColumns) == false ||
        _width != widget.stateManager.leftFixedColumnsWidth) {
      setState(() {
        _columns = widget.stateManager.leftFixedColumns;
        _width = widget.stateManager.leftFixedColumnsWidth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _columns.length,
        itemBuilder: (ctx, i) {
          return HeaderWidget(
            stateManager: widget.stateManager,
            column: _columns[i],
          );
        },
      ),
    );
  }
}
