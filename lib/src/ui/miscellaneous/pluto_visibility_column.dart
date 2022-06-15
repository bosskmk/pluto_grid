import 'package:flutter/material.dart';

import '../../../pluto_grid.dart';

mixin VisibilityColumnWidget implements Widget {
  PlutoColumn get column;
}

class PlutoVisibilityReplacementWidget extends ConstrainedBox {
  PlutoVisibilityReplacementWidget({
    Key? key,
    required super.constraints,
  }) : super(key: key);
}

class PlutoVisibilityColumn extends StatelessWidget {
  final VisibilityColumnWidget child;

  final PlutoGridStateManager stateManager;

  const PlutoVisibilityColumn({
    required this.child,
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

    return PlutoVisibilityReplacementWidget(
      constraints: BoxConstraints.tightFor(
        width: child.column.width,
        height: stateManager.rowHeight,
      ),
    );
  }
}

class PlutoVisibilityColumnElement extends StatelessElement {
  PlutoVisibilityColumnElement(
    super.widget, {
    required this.stateManager,
  });

  final PlutoGridStateManager stateManager;

  @override
  void mount(Element? parent, Object? newSlot) {
    stateManager.visibilityBuildController.addVisibilityColumnElement(
      field: (widget as PlutoVisibilityColumn).child.column.field,
      element: this,
    );

    super.mount(parent, newSlot);
  }

  @override
  void unmount() {
    stateManager.visibilityBuildController.removeVisibilityColumnElement(
      field: (widget as PlutoVisibilityColumn).child.column.field,
      element: this,
    );

    super.unmount();
  }
}
