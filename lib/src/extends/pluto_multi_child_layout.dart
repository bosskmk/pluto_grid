import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pluto_grid/pluto_grid.dart';

typedef PlutoVisibilityListener = void Function(Iterable<Element> children);

class PlutoMultiChildLayout extends PlutoMultiChildRenderObjectWidget {
  PlutoMultiChildLayout({
    super.key,
    required this.delegate,
    required super.stateManager,
    required super.visibilityListener,
    super.children,
  });

  final MultiChildLayoutDelegate delegate;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return PlutoRenderCustomMultiChildLayoutBox(delegate: delegate);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderCustomMultiChildLayoutBox renderObject) {
    renderObject.delegate = delegate;
  }
}

class PlutoRenderCustomMultiChildLayoutBox
    extends RenderCustomMultiChildLayoutBox {
  PlutoRenderCustomMultiChildLayoutBox({
    super.children,
    required super.delegate,
  });
}

abstract class PlutoMultiChildRenderObjectWidget
    extends MultiChildRenderObjectWidget {
  PlutoMultiChildRenderObjectWidget({
    super.key,
    super.children,
    required this.stateManager,
    required this.visibilityListener,
  });

  final PlutoGridStateManager stateManager;

  final PlutoVisibilityListener visibilityListener;

  @override
  MultiChildRenderObjectElement createElement() =>
      PlutoMultiChildRenderObjectElement(
        this,
        stateManager: stateManager,
        visibilityListener: visibilityListener,
      );
}

class PlutoMultiChildRenderObjectElement extends MultiChildRenderObjectElement {
  PlutoMultiChildRenderObjectElement(
    super.widget, {
    required this.stateManager,
    required this.visibilityListener,
  });

  final PlutoGridStateManager stateManager;

  final PlutoVisibilityListener visibilityListener;

  void listener() {
    visibilityListener(children);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    // print('mount');
    stateManager.visibilityNotifier.addListener(listener);
    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    // print('unmount');
    stateManager.visibilityNotifier.removeListener(listener);
    super.unmount();
  }
}
