import 'package:example/screen/configuration_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screen/add_and_remove_screen.dart';
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
      initialRoute:
          kReleaseMode ? HomeScreen.routeName : DualGridScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(),
        NormalGridScreen.routeName: (context) => NormalGridScreen(),
        DualGridScreen.routeName: (context) => DualGridScreen(),
        AddAndRemoveScreen.routeName: (context) => AddAndRemoveScreen(),
        ConfigurationScreen.routeName: (context) => ConfigurationScreen(),
      },
    );
  }
}
