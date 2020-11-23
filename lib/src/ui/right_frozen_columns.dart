part of '../../pluto_grid.dart';

class RightFrozenColumns extends StatefulWidget {
  final PlutoStateManager stateManager;

  RightFrozenColumns(this.stateManager);

  @override
  _RightFrozenColumnsState createState() => _RightFrozenColumnsState();
}

class _RightFrozenColumnsState extends State<RightFrozenColumns> {
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

    _columns = widget.stateManager.rightFrozenColumns;
    _width = widget.stateManager.rightFrozenColumnsWidth;

    widget.stateManager.addListener(changeStateListener);
  }

  void changeStateListener() {
    if (listEquals(_columns, widget.stateManager.rightFrozenColumns) == false ||
        _width != widget.stateManager.rightFrozenColumnsWidth) {
      setState(() {
        _columns = widget.stateManager.rightFrozenColumns;
        _width = widget.stateManager.rightFrozenColumnsWidth;
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
