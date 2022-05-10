import 'package:url_launcher/url_launcher.dart';

void launchUrl(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    launchUrl(url);
  }
}
