import 'package:flutter/material.dart';

import '../screen/dual_grid_screen.dart';
import '../screen/home_screen.dart';
import '../screen/normal_grid_screen.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'PlutoGrid',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              Navigator.pushReplacementNamed(context, HomeScreen.routeName);
            },
          ),
          ListTile(
            title: Text('Normal Grid Demo'),
            onTap: () {
              Navigator.popAndPushNamed(context, NormalGridScreen.routeName);
            },
          ),
          ListTile(
            title: Text('Dual Grid Demo'),
            onTap: () {
              Navigator.popAndPushNamed(context, DualGridScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
