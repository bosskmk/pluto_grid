import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../pluto_grid.dart';

mixin VisibilityColumnWidget implements Widget {
  PlutoColumn get column;
}

class PlutoVisibilityReplacementWidget extends SizedBox {
  const PlutoVisibilityReplacementWidget({
    Key? key,
  }) : super.shrink(key: key);
}

class PlutoVisibilityColumn extends StatelessWidget {
  final VisibilityColumnWidget child;

  final Widget replacement;

  final PlutoGridStateManager stateManager;

  const PlutoVisibilityColumn({
    required this.child,
    this.replacement = const PlutoVisibilityReplacementWidget(),
    required this.stateManager,
    required Key key,
  }) : super(key: key);

  @override
  PlutoVisibilityColumnElement createElement() => PlutoVisibilityColumnElement(
        this,
        stateManager: stateManager,
      );

  @override
  Widget build(BuildContext context) {
    if ((stateManager.showFrozenColumn && child.column.frozen.isFrozen) ||
        child.column.visible) {
      return child;
    }

    return replacement;
  }
}

class PlutoVisibilityColumnElement extends StatelessElement {
  PlutoVisibilityColumnElement(
    super.widget, {
    required this.stateManager,
  });

  final PlutoGridStateManager stateManager;

  bool mounted = false;

  @override
  void mount(Element? parent, Object? newSlot) {
    stateManager.visibilityBuildController.addVisibilityColumnElement(
      field: (widget as PlutoVisibilityColumn).child.column.field,
      element: this,
    );

    super.mount(parent, newSlot);

    mounted = true;
  }

  @override
  void unmount() {
    stateManager.visibilityBuildController.removeVisibilityColumnElement(
      field: (widget as PlutoVisibilityColumn).child.column.field,
      element: this,
    );

    super.unmount();

    mounted = false;
  }
}

class PlutoIgnoreParentNeedsLayout extends SingleChildRenderObjectWidget {
  const PlutoIgnoreParentNeedsLayout({
    Key? key,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _Render();
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {}
}

class _Render extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  @override
  void markParentNeedsLayout() {
    return;
  }

  @override
  void performLayout() {
    child!.layout(constraints);
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, offset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (child == null || child is RenderConstrainedBox) {
      return false;
    }

    return child!.hitTest(result, position: position);
  }
}
