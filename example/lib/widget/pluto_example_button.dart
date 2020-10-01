import 'package:example/helper/launch_url.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlutoExampleButton extends StatelessWidget {
  final String url;

  PlutoExampleButton({
    this.url,
  }) : assert(url.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
      onPressed: () {
        launchUrl(url);
      },
      icon: FaIcon(FontAwesomeIcons.github),
      label: Text('Source'),
    );
  }
}
