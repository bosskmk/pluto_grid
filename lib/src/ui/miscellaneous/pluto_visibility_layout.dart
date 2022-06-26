import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// It is used to lay out the widgets
/// of [PlutoCell] or [PlutoColumn], [PlutoColumnGroup] of [PlutoRow]
/// or render only the widgets displayed according to the screen width.
class PlutoVisibilityLayout extends CustomMultiChildLayout {
  PlutoVisibilityLayout({
    super.key,
    required super.children,
    required super.delegate,
    required this.scrollController,
    this.initialViewportDimension = 1920,
  });

  final ScrollController scrollController;

  /// When the viewportDimension of scrollPosition cannot be obtained in the first build stage,
  /// it is used instead of viewportDimension of scroll.
  final double initialViewportDimension;

  @override
  PlutoVisibilityLayoutRenderObjectElement createElement() =>
      PlutoVisibilityLayoutRenderObjectElement(
        widget: this,
        scrollController: scrollController,
        initialViewportDimension: initialViewportDimension,
      );

  @override
  RenderCustomMultiChildLayoutBox createRenderObject(BuildContext context) {
    return RenderCustomMultiChildLayoutBox(delegate: delegate);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderCustomMultiChildLayoutBox renderObject,
  ) {
    renderObject.delegate = delegate;
  }
}

class PlutoVisibilityLayoutRenderObjectElement extends RenderObjectElement
    implements MultiChildRenderObjectElement {
  PlutoVisibilityLayoutRenderObjectElement({
    required PlutoVisibilityLayout widget,
    required this.scrollController,
    this.initialViewportDimension = 1920,
  })  : assert(!debugChildrenHaveDuplicateKeys(widget, widget.children)),
        super(widget);

  final ScrollController scrollController;

  final double initialViewportDimension;

  @override
  ContainerRenderObjectMixin<RenderObject,
      ContainerParentDataMixin<RenderObject>> get renderObject {
    return super.renderObject as ContainerRenderObjectMixin<RenderObject,
        ContainerParentDataMixin<RenderObject>>;
  }

  @override
  @protected
  @visibleForTesting
  Iterable<Element> get children => _children.where((Element child) {
        return !_forgottenChildren.contains(child);
      });

  late List<Element> _children;

  final Set<Element> _forgottenChildren = HashSet<Element>();

  double get visibleLeft => scrollController.offset;

  double get visibleRight {
    try {
      return visibleLeft + scrollController.position.viewportDimension;
    } catch (e) {
      return visibleLeft + initialViewportDimension;
    }
  }

  double _lastMaxScroll = 0;

  double _lastVisibleStartX1 = 0;

  double _lastVisibleStartX2 = 0;

  double _lastVisibleEndX1 = 0;

  double _lastVisibleEndX2 = 0;

  bool _firstVisible = true;

  void scrollListener() {
    final bool sameBoundScroll = _lastVisibleStartX1 <= visibleLeft &&
        visibleLeft <= _lastVisibleStartX2 &&
        _lastVisibleEndX1 <= visibleRight &&
        visibleRight <= _lastVisibleEndX2;

    if (sameBoundScroll &&
        _lastMaxScroll == scrollController.position.maxScrollExtent) {
      return;
    }

    _lastMaxScroll = scrollController.position.maxScrollExtent;

    markNeedsBuild();
  }

  bool visible({
    required double startOffset,
    required PlutoVisibilityLayoutChild layoutChild,
  }) {
    return layoutChild.keepAlive ||
        (startOffset <= visibleRight &&
            startOffset + layoutChild.width >= visibleLeft);
  }

  void updateLastVisible({
    required double startOffset,
    required double width,
  }) {
    if (_firstVisible) {
      _lastVisibleStartX1 = startOffset;
      _lastVisibleStartX2 = startOffset + width;
      _firstVisible = false;
    }

    _lastVisibleEndX1 = startOffset;
    _lastVisibleEndX2 = startOffset + width;
  }

  PlutoVisibilityLayoutChild getLayoutChild(Widget child) {
    assert(child is PlutoVisibilityLayoutId);
    return (child as PlutoVisibilityLayoutId).layoutChild;
  }

  Element? findChildByLayoutId(Object layoutId) {
    return _children.firstWhereOrNull((element) {
      if (element.widget is PlutoVisibilityLayoutId) {
        return (element.widget as PlutoVisibilityLayoutId).id == layoutId;
      }
      return false;
    });
  }

  @override
  void performRebuild() {
    super.performRebuild();

    final PlutoVisibilityLayout layoutWidget = widget as PlutoVisibilityLayout;

    final visibleWidgets = <Widget>[];
    final slots = <IndexedSlot>[];

    Element? previousChild;
    double startOffset = 0;
    _firstVisible = true;

    for (int i = 0; i < layoutWidget.children.length; i += 1) {
      final child = layoutWidget.children[i] as PlutoVisibilityLayoutId;
      final layoutChild = getLayoutChild(child);
      final width = layoutChild.width;

      if (visible(startOffset: startOffset, layoutChild: layoutChild)) {
        final foundElement = findChildByLayoutId(child.id);

        if (foundElement != null) {
          visibleWidgets.add(foundElement.widget);
          slots.add(IndexedSlot<Element?>(i, previousChild));
          previousChild = foundElement;
        } else {
          final element = child.createElement();
          visibleWidgets.add(element.widget);
          slots.add(IndexedSlot<Element?>(i, previousChild));
          previousChild = element;
        }

        updateLastVisible(startOffset: startOffset, width: width);
      }

      startOffset += width;
    }

    for (final child in _children) {
      if (child is _NullElement) {
        continue;
      }

      final layoutChild = getLayoutChild(child.widget);

      if (!visible(
        startOffset: layoutChild.startPosition,
        layoutChild: layoutChild,
      )) {
        deactivateChild(child);
        _forgottenChildren.add(child);
      }
    }

    _children = updateChildren(
      _children,
      visibleWidgets,
      forgottenChildren: _forgottenChildren,
      slots: slots,
    );

    _forgottenChildren.clear();
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);

    scrollController.addListener(scrollListener);

    final PlutoVisibilityLayout layoutWidget = widget as PlutoVisibilityLayout;

    final List<Element> children = List<Element>.filled(
      layoutWidget.children.length,
      _NullElement.instance,
    );

    Element? previousChild;
    double startOffset = 0;
    _firstVisible = true;

    for (int i = 0; i < children.length; i += 1) {
      final layoutChild = getLayoutChild(layoutWidget.children[i]);
      final width = layoutChild.width;

      if (visible(startOffset: startOffset, layoutChild: layoutChild)) {
        final Element newChild = inflateWidget(
          layoutWidget.children[i],
          IndexedSlot<Element?>(i, previousChild),
        );
        children[i] = newChild;
        previousChild = newChild;

        updateLastVisible(startOffset: startOffset, width: width);
      } else {
        _forgottenChildren.add(children[i]);
      }

      startOffset += width;
    }

    _children = children;
  }

  @override
  void unmount() {
    super.unmount();

    scrollController.removeListener(scrollListener);
  }

  @override
  void update(PlutoVisibilityLayout newWidget) {
    super.update(newWidget);

    final PlutoVisibilityLayout layoutWidget = widget as PlutoVisibilityLayout;

    assert(widget == newWidget);

    assert(!debugChildrenHaveDuplicateKeys(
      widget,
      layoutWidget.children,
    ));

    final List<Widget> visibleWidgets = [];
    double startOffset = 0;
    _firstVisible = true;

    for (int i = 0; i < layoutWidget.children.length; i += 1) {
      final layoutChild = getLayoutChild(layoutWidget.children[i]);
      final width = layoutChild.width;

      if (visible(startOffset: startOffset, layoutChild: layoutChild)) {
        visibleWidgets.add(layoutWidget.children[i]);

        updateLastVisible(startOffset: startOffset, width: width);
      }

      startOffset += width;
    }

    _children = updateChildren(
      _children,
      visibleWidgets,
      forgottenChildren: _forgottenChildren,
    );

    _forgottenChildren.clear();
  }

  @override
  void insertRenderObjectChild(RenderObject child, IndexedSlot<Element?> slot) {
    final ContainerRenderObjectMixin<RenderObject,
            ContainerParentDataMixin<RenderObject>> renderObject =
        this.renderObject;
    assert(renderObject.debugValidateChild(child));
    renderObject.insert(child, after: slot.value?.renderObject);
    assert(renderObject == this.renderObject);
  }

  @override
  void moveRenderObjectChild(RenderObject child, IndexedSlot<Element?> oldSlot,
      IndexedSlot<Element?> newSlot) {
    final ContainerRenderObjectMixin<RenderObject,
            ContainerParentDataMixin<RenderObject>> renderObject =
        this.renderObject;
    assert(child.parent == renderObject);
    renderObject.move(child, after: newSlot.value?.renderObject);
    assert(renderObject == this.renderObject);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    final ContainerRenderObjectMixin<RenderObject,
            ContainerParentDataMixin<RenderObject>> renderObject =
        this.renderObject;
    assert(child.parent == renderObject);
    renderObject.remove(child);
    assert(renderObject == this.renderObject);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    for (final Element child in _children) {
      if (!_forgottenChildren.contains(child)) visitor(child);
    }
  }

  @override
  void forgetChild(Element child) {
    assert(_children.contains(child));
    assert(!_forgottenChildren.contains(child));
    _forgottenChildren.add(child);
    super.forgetChild(child);
  }

  @override
  Element inflateWidget(Widget newWidget, Object? newSlot) {
    final Element newChild = super.inflateWidget(newWidget, newSlot);
    assert(_debugCheckHasAssociatedRenderObject(newChild));
    return newChild;
  }

  bool _debugCheckHasAssociatedRenderObject(Element newChild) {
    assert(() {
      if (newChild.renderObject == null) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: FlutterError.fromParts(<DiagnosticsNode>[
              ErrorSummary(
                  'The children of `MultiChildRenderObjectElement` must each has an associated render object.'),
              ErrorHint(
                'This typically means that the `${newChild.widget}` or its children\n'
                'are not a subtype of `RenderObjectWidget`.',
              ),
              newChild.describeElement(
                  'The following element does not have an associated render object'),
              DiagnosticsDebugCreator(DebugCreator(newChild)),
            ]),
          ),
        );
      }
      return true;
    }());
    return true;
  }
}

class PlutoVisibilityLayoutId extends LayoutId {
  PlutoVisibilityLayoutId({
    Key? key,
    required super.id,
    required PlutoVisibilityLayoutChild child,
  }) : super(key: key, child: RepaintBoundary(child: child));

  PlutoVisibilityLayoutChild get layoutChild =>
      (child as RepaintBoundary).child as PlutoVisibilityLayoutChild;
}

abstract class PlutoVisibilityLayoutChild implements Widget {
  double get width;

  double get startPosition;

  bool get keepAlive => false;
}

class _NullElement extends Element {
  _NullElement() : super(const _NullWidget());

  static _NullElement instance = _NullElement();

  @override
  bool get debugDoingBuild => throw UnimplementedError();

  @override
  void performRebuild() => throw UnimplementedError();
}

class _NullWidget extends Widget {
  const _NullWidget();

  @override
  Element createElement() => throw UnimplementedError();
}
