import 'package:flutter/material.dart';

import 'screen/dual_grid_screen.dart';
import 'screen/home_screen.dart';
import 'screen/normal_grid_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(),
        NormalGridScreen.routeName: (context) => NormalGridScreen(),
        DualGridScreen.routeName: (context) => DualGridScreen(),
      },
    );
  }
}
