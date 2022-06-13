import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../pluto_grid.dart';
import '../../manager/state/visibility_state.dart';

mixin VisibilityColumnWidget implements Widget {
  PlutoColumn get column;
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

    if (stateManager.showFrozenColumn && child.column.frozen.isFrozen) {
      return child;
    }

    final visible = context.select<VisibilityStateNotifier, bool>((value) {
      return value.visibleColumn(child.column);
    });

    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(
        width: child.column.width,
        height: stateManager.rowHeight,
      ),
      child: visible ? child : null,
    );
  }
}
