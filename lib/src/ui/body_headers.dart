part of '../../pluto_grid.dart';

class BodyHeaders extends StatefulWidget {
  final PlutoStateManager stateManager;

  BodyHeaders(this.stateManager);

  @override
  _BodyHeadersState createState() => _BodyHeadersState();
}

class _BodyHeadersState extends State<BodyHeaders> {
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
    _columns = getColumns();

    _width = getWidth();

    scroll = widget.stateManager.scroll.horizontal.addAndGet();

    widget.stateManager.addListener(changeStateListener);

    super.initState();
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
    return widget.stateManager.layout.showFixedColumn
        ? widget.stateManager.bodyColumns
        : widget.stateManager.columns;
  }

  double getWidth() {
    return widget.stateManager.layout.showFixedColumn
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
          return HeaderWidget(
            stateManager: widget.stateManager,
            column: _columns[i],
          );
        },
      ),
    );
  }
}
