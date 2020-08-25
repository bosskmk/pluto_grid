part of '../../pluto_grid.dart';

class ClipboardTransformation {
  static List<List<String>> stringToList(String text) {
    return text
        .split(RegExp('\n|\r\n'))
        .map((text) => text.split('\t'))
        .toList();
  }
}
