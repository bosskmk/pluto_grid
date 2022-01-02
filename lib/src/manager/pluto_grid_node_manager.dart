import 'package:pluto_grid/pluto_grid.dart';

import 'node/pluto_row_node.dart';

class PlutoGridNodeManager {
  final PlutoGridStateManager stateManager;

  PlutoGridNodeManager({
    required this.stateManager,
  });

  late final PlutoRowNode rootRowNode;

  generateRowNodes() {
    int index = 0;

    setNode(PlutoRowNode node) {
      return (PlutoRowNode nextNode) {
        nextNode.up = node;
        node.down = nextNode;
      };
    }

    void Function(PlutoRowNode nextNode)? setNodeFunc;

    for (var row in stateManager.refRows) {
      final node = PlutoRowNode<PlutoRow>(
        index: index++,
        data: row,
      );

      if (setNodeFunc != null) {
        setNodeFunc(node);
      } else {
        rootRowNode = node;
      }

      setNodeFunc = setNode(node);
    }
  }
}
