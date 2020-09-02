import 'package:flutter/material.dart';

class Link extends StatelessWidget {
  final String title;
  final String description;
  final String url;

  Link({this.title, this.description, this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 220,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 21,
            ),
          ),
          SelectableText(url),
          Text(description),
        ],
      ),
    );
  }
}
