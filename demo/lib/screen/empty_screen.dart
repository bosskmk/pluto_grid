import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../dummy_data/development.dart';

class EmptyScreen extends StatefulWidget {
  static const routeName = 'empty';

  const EmptyScreen({Key? key}) : super(key: key);

  @override
  _EmptyScreenState createState() => _EmptyScreenState();
}

class _EmptyScreenState extends State<EmptyScreen> {
  late List<PlutoColumn> columns;

  late List<PlutoRow> rows;

  late PlutoGridStateManager stateManager;

  final gridAProps = PlutoDualGridProps(
    columns: [],
    rows: [],
  );

  final gridBProps = PlutoDualGridProps(
    columns: [],
    rows: [],
  );

  @override
  void initState() {
    super.initState();

    final gridAData = DummyData(10, 100);
    final gridBData = DummyData(10, 100);

    gridAProps.columns.addAll(gridAData.columns);
    gridAProps.rows.addAll(gridAData.rows);

    gridBProps.columns.addAll(gridBData.columns);
    gridBProps.rows.addAll(gridBData.rows);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: PlutoDualGrid(
          gridPropsA: gridAProps,
          gridPropsB: gridBProps,
        ),
      ),
    );
  }
}
// borderColor: widget.gridPropsA.configuration.gridBorderColor,
// backgroundColor:
// widget.gridPropsA.configuration.gridBackgroundColor,
// indicatorColor: widget.gridPropsA.configuration.gridBorderColor,
// draggingColor: widget.gridPropsA.configuration.activatedColor,
