import 'package:flutter/material.dart';

class DescendantElementHelper {
  DescendantElementHelper(this.elements);

  final Iterable<Element> elements;

  List<Element> findByWidgetType<T>() {
    final List<Element> found = [];

    void visitor(Element element) {
      if (element.widget is T) {
        found.add(element);
      }

      element.visitChildElements(visitor);
    }

    for (final child in elements) {
      if (child.widget is T) {
        found.add(child);
      }

      child.visitChildElements(visitor);
    }

    return found;
  }
}
