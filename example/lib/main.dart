import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'dummy_data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlutoGrid Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dummyData = DummyData(10, 30);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('PlutoGrid Demo'),
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: PlutoGrid(
          columns: dummyData.dummyColumns, // or dummyData.dummyColumns,
          rows: dummyData.dummyRows, // or dummyData.dummyRows,
        ),
      ),
    );
  }
}
