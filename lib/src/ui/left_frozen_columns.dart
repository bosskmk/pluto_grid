part of '../../pluto_grid.dart';

class LeftFrozenColumns extends StatefulWidget {
  final PlutoStateManager stateManager;

  LeftFrozenColumns(this.stateManager);

  @override
  _LeftFrozenColumnsState createState() => _LeftFrozenColumnsState();
}

class _LeftFrozenColumnsState extends State<LeftFrozenColumns> {
  List<PlutoColumn> _columns;
  double _width;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _columns = widget.stateManager.leftFrozenColumns;
    _width = widget.stateManager.leftFrozenColumnsWidth;

    widget.stateManager.addListener(changeStateListener);
  }

  void changeStateListener() {
    if (listEquals(_columns, widget.stateManager.leftFrozenColumns) == false ||
        _width != widget.stateManager.leftFrozenColumnsWidth) {
      setState(() {
        _columns = widget.stateManager.leftFrozenColumns;
        _width = widget.stateManager.leftFrozenColumnsWidth;
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
