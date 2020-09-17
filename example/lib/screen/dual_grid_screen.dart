import 'package:example/widget/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../dummy_data/development.dart';

class DualGridScreen extends StatelessWidget {
  static const routeName = 'dual-grid';

  final dummyDataA = DummyData(10, 100);
  final dummyDataB = DummyData(10, 100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PlutoGrid - Dual'),
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
