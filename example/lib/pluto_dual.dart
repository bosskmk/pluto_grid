import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'dummy_data/development.dart';

class PlutoDual extends StatefulWidget {
  @override
  _PlutoDualState createState() => _PlutoDualState();
}

class _PlutoDualState extends State<PlutoDual> {
  final dummyDataA = DummyData(10, 100);
  final dummyDataB = DummyData(10, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('PlutoGrid Demo'),
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: PlutoDualGrid(
          gridPropsA: PlutoDualGridProps(
            columns: dummyDataA.columns,
            rows: dummyDataA.rows,
            onChanged: (PlutoOnChangedEvent event) {
              print(event);
            },
          ),
          gridPropsB: PlutoDualGridProps(
            columns: dummyDataB.columns,
            rows: dummyDataB.rows,
            onChanged: (PlutoOnChangedEvent event) {
              print(event);
            },
          ),
        ),
      ),
    );
  }
}
