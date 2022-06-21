import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../pluto_grid.dart';

class PlutoVisibilityLayout extends CustomMultiChildLayout {
  PlutoVisibilityLayout({
    super.key,
    required super.children,
    required super.delegate,
    required this.stateManager,
  });

  final PlutoGridStateManager stateManager;

  @override
  PlutoVisibilityLayoutRenderObjectElement createElement() =>
      PlutoVisibilityLayoutRenderObjectElement(this, stateManager);

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
  PlutoVisibilityLayoutRenderObjectElement(
    PlutoVisibilityLayout widget,
    this.stateManager,
  )   : assert(!debugChildrenHaveDuplicateKeys(widget, widget.children)),
        super(widget);

  final PlutoGridStateManager stateManager;

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
  // We keep a set of forgotten children to avoid O(n^2) work walking _children
  // repeatedly to remove children.
  final Set<Element> _forgottenChildren = HashSet<Element>();

  void scrollListener() {
    markNeedsBuild();
  }

  @override
  void performRebuild() {
    super.performRebuild();

    final MultiChildRenderObjectWidget renderWidget =
        widget as MultiChildRenderObjectWidget;

    Element? findByLayoutId(Object layoutId) {
      return _children.firstWhereOrNull((element) {
        if (element is _NullElement ||
            element.widget is! PlutoVisibilityLayoutId) {
          return false;
        }
        return (element.widget as PlutoVisibilityLayoutId).id == layoutId;
      });
    }

    final visibleWidgets = <Widget>[];
    final slots = <IndexedSlot>[];
    Element? previousChild;

    /// visible 컬럼만 체크
    for (int i = 0; i < renderWidget.children.length; i += 1) {
      final child = renderWidget.children[i];
      final childWidget = child as PlutoVisibilityLayoutId;

      if (!(childWidget.child as PlutoVisibilityLayoutChild).visible()) {
        continue;
      }

      final foundElement = findByLayoutId(childWidget.id);

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
    }

    /// 기존 자식에서 비활성화 된 것만 체크
    for (final child in _children) {
      if (child is _NullElement || child.widget is! PlutoVisibilityLayoutId) {
        continue;
      }

      final childWidget = ((child.widget as PlutoVisibilityLayoutId).child
          as PlutoVisibilityLayoutChild);

      if (!childWidget.visible()) {
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

  @override
  Element inflateWidget(Widget newWidget, Object? newSlot) {
    final Element newChild = super.inflateWidget(newWidget, newSlot);
    assert(_debugCheckHasAssociatedRenderObject(newChild));
    return newChild;
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);

    stateManager.visibilityBuildController.addListener(scrollListener);

    final MultiChildRenderObjectWidget childrenWidgets =
        widget as MultiChildRenderObjectWidget;

    final List<Element> children = List<Element>.filled(
      childrenWidgets.children.length,
      _NullElement.instance,
    );

    Element? previousChild;

    for (int i = 0; i < children.length; i += 1) {
      if (!((childrenWidgets.children[i] as PlutoVisibilityLayoutId).child
              as PlutoVisibilityLayoutChild)
          .visible()) {
        _forgottenChildren.add(children[i]);
      } else {
        final Element newChild = inflateWidget(
          childrenWidgets.children[i],
          IndexedSlot<Element?>(i, previousChild),
        );

        children[i] = newChild;

        previousChild = newChild;
      }
    }

    _children = children;
  }

  @override
  void unmount() {
    stateManager.visibilityBuildController.removeListener(scrollListener);
    super.unmount();
  }

  @override
  void update(PlutoVisibilityLayout newWidget) {
    super.update(newWidget);

    final PlutoVisibilityLayout multiChildRenderObjectWidget =
        widget as PlutoVisibilityLayout;

    assert(widget == newWidget);

    assert(!debugChildrenHaveDuplicateKeys(
      widget,
      multiChildRenderObjectWidget.children,
    ));

    _children = updateChildren(
      _children,
      multiChildRenderObjectWidget.children
          .where((e) => ((e as PlutoVisibilityLayoutId).child
                  as PlutoVisibilityLayoutChild)
              .visible())
          .toList(),
      forgottenChildren: _forgottenChildren,
    );

    _forgottenChildren.clear();
  }
}

class PlutoVisibilityLayoutId extends LayoutId {
  PlutoVisibilityLayoutId({
    Key? key,
    required super.id,
    required PlutoVisibilityLayoutChild child,
  }) : super(key: key, child: child);
}

abstract class PlutoVisibilityLayoutChild implements Widget {
  bool visible();
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
