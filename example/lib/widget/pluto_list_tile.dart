import 'package:example/constants/pluto_colors.dart';
import 'package:flutter/material.dart';

class PlutoListTile extends StatelessWidget {
  final String title;

  final String description;

  final List<String> tags;

  final Function() onTap;

  PlutoListTile({
    @required this.title,
    this.description,
    this.tags,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 300,
        maxWidth: 300,
      ),
      child: Card(
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (description != null)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    description,
                    style: TextStyle(
                      color: PlutoColors.fontColor,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                ),
              if (tags != null && tags.length > 0)
                Wrap(
                  spacing: 10,
                  children: tags.map((String tag) {
                    return Chip(
                      avatar: CircleAvatar(
                        backgroundColor: Colors.grey.shade800,
                        child: Text(tag[0]),
                      ),
                      label: Text(tag),
                    );
                  }).toList(),
                ),
            ],
          ),
          contentPadding: EdgeInsets.all(15),
          onTap: () {
            if (onTap != null) {
              onTap();
            }
          },
        ),
      ),
    );
  }
}
