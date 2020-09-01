import 'package:flutter/material.dart';

import 'pluto_normal.dart';
import 'pluto_dual.dart';

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
      ),
      // home: PlutoNormal(),
      home: PlutoDual(),
    );
  }
}
