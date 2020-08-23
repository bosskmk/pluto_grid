part of pluto_grid;

class ClipboardTransformation {
  static List<List<String>> stringToList(String text) {
    return text
        .split('\n')
        .map((text) => text.split('\t'))
        .toList();
  }
}
