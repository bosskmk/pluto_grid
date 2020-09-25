part of '../../pluto_grid.dart';

class LeftFixedColumns extends StatefulWidget {
  final PlutoStateManager stateManager;

  LeftFixedColumns(this.stateManager);

  @override
  _LeftFixedColumnsState createState() => _LeftFixedColumnsState();
}

class _LeftFixedColumnsState extends State<LeftFixedColumns> {
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
          return ColumnWidget(
            stateManager: widget.stateManager,
            column: _columns[i],
          );
        },
      ),
    );
  }
}
