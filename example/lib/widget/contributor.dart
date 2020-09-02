import 'package:flutter/material.dart';

class Contributor extends StatelessWidget {
  final String profile;
  final String name;
  final String description;
  final String homepage;

  Contributor({this.profile, this.name, this.description, this.homepage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            alignment: WrapAlignment.center,
            direction: Axis.horizontal,
            children: [
              Center(
                child: ClipOval(
                  child: Container(
                    height: 110,
                    width: 110,
                    color: Colors.grey.shade200,
                    child: Image.asset(
                      profile,
                      width: 110,
                      height: 110,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 21,
                    ),
                  ),
                  SelectableText(homepage),
                  Text(description),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
