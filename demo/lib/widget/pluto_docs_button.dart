import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../helper/launch_url.dart';

class PlutoDocsButton extends StatelessWidget {
  final String url;

  PlutoDocsButton({
    super.key,
    required this.url,
  })  : assert(url.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        launchUrl(url);
      },
      icon: const FaIcon(FontAwesomeIcons.book),
      label: const Text('Documentation'),
    );
  }
}
