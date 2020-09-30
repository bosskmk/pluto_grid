import 'package:example/constants/pluto_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screen/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: kReleaseMode ? HomeScreen.routeName : HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (context) => HomeScreen(),
      },
      theme: ThemeData(
        primaryColor: PlutoColors.primaryColor,
        fontFamily: 'OpenSans',
        backgroundColor: PlutoColors.backgroundColor,
        scaffoldBackgroundColor: PlutoColors.backgroundColor,
      ),
    );
  }
}
