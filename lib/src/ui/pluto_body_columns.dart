part of '../../pluto_grid.dart';

class PlutoBodyColumns extends StatefulWidget {
  final PlutoStateManager stateManager;

  PlutoBodyColumns(this.stateManager);

  @override
  _PlutoBodyColumnsState createState() => _PlutoBodyColumnsState();
}

class _PlutoBodyColumnsState extends State<PlutoBodyColumns> {
  List<PlutoColumn> _columns;

  double _width;

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

    _columns = getColumns();

    _width = getWidth();

    scroll = widget.stateManager.scroll.horizontal.addAndGet();

    widget.stateManager.addListener(changeStateListener);
  }

  void changeStateListener() {
    List<PlutoColumn> changedColumns = getColumns();
    double changedWidth = getWidth();

    if (listEquals(_columns, changedColumns) == false ||
        _width != changedWidth) {
      setState(() {
        _columns = changedColumns;
        _width = changedWidth;
      });
    }
  }

  List<PlutoColumn> getColumns() {
    return widget.stateManager.showFrozenColumn
        ? widget.stateManager.bodyColumns
        : widget.stateManager.columns;
  }

  double getWidth() {
    return widget.stateManager.showFrozenColumn
        ? widget.stateManager.bodyColumnsWidth
        : widget.stateManager.columnsWidth;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: ListView.builder(
        controller: scroll,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _columns.length,
        itemBuilder: (ctx, i) {
          return PlutoBaseColumn(
            stateManager: widget.stateManager,
            column: _columns[i],
          );
        },
      ),
    );
  }
}
