import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  const PlutoVisibilityColumn({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stateManager = context.read<PlutoGridStateManager>();

    if ((stateManager.showFrozenColumn && child.column.frozen.isFrozen) ||
        stateManager.visibilityNotifier.visibleColumn(child.column)) {
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
