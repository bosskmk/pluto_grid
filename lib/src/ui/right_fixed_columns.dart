part of '../../pluto_grid.dart';

class RightFixedColumns extends StatefulWidget {
  final PlutoStateManager stateManager;

  RightFixedColumns(this.stateManager);

  @override
  _RightFixedColumnsState createState() => _RightFixedColumnsState();
}

class _RightFixedColumnsState extends State<RightFixedColumns> {
  List<PlutoColumn> _columns;
  double _width;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);
    super.dispose();
  }

  @override
  void initState() {
    _columns = widget.stateManager.rightFixedColumns;
    _width = widget.stateManager.rightFixedColumnsWidth;

    widget.stateManager.addListener(changeStateListener);

    super.initState();
  }

  void changeStateListener() {
    if (listEquals(_columns, widget.stateManager.rightFixedColumns) == false ||
        _width != widget.stateManager.rightFixedColumnsWidth) {
      setState(() {
        _columns = widget.stateManager.rightFixedColumns;
        _width = widget.stateManager.rightFixedColumnsWidth;
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
