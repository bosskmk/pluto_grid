import 'package:url_launcher/url_launcher.dart' as url_launcher;

void launchUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (await url_launcher.canLaunchUrl(uri)) {
    url_launcher.launchUrl(uri);
  }
}
