import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../ui/columns/pluto_column_title.dart';

abstract class PlutoColumnMenuDelegate<T> {
  List<PopupMenuEntry<T>> buildMenuItems({
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
  });

  void onSelected({
    required BuildContext context,
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
    required bool mounted,
    required T? selected,
  });
}

class PlutoColumnMenuDelegateDefault implements PlutoColumnMenuDelegate<PlutoGridColumnMenuItem> {
  const PlutoColumnMenuDelegateDefault();

  @override
  List<PopupMenuEntry<PlutoGridColumnMenuItem>> buildMenuItems({
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
  }) {
    return _getDefaultColumnMenuItems(
      stateManager: stateManager,
      column: column,
    );
  }

  @override
  void onSelected({
    required BuildContext context,
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
    required bool mounted,
    required PlutoGridColumnMenuItem? selected,
  }) {
    if (isFiltered == false) {
      switch (selected) {
        case PlutoGridColumnMenuItem.setFilter:
          stateManager.showFilterPopup(context, calledColumn: column);
          break;
        default:
          break;
      }
    } else {
      null;
    }
  }
}

/// Open the context menu on the right side of the column.
Future<T?>? showColumnMenu<T>({
  required BuildContext context,
  required Offset position,
  required List<PopupMenuEntry<T>> items,
  Color backgroundColor = Colors.white,
}) {
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

  return showMenu<T>(
    context: context,
    color: backgroundColor,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx + overlay.size.width,
      position.dy + overlay.size.height,
    ),
    items: items,
    useRootNavigator: true,
  );
}

List<PopupMenuEntry<PlutoGridColumnMenuItem>> _getDefaultColumnMenuItems({
  required PlutoGridStateManager stateManager,
  required PlutoColumn column,
}) {
  final Color textColor = stateManager.style.cellTextStyle.color!;
  final localeText = stateManager.localeText;

  return [
    _buildMenuItem(
      value: PlutoGridColumnMenuItem.setFilter,
      text: localeText.setFilter,
      textColor: textColor,
    ),
  ];
}

PopupMenuItem<PlutoGridColumnMenuItem> _buildMenuItem<PlutoGridColumnMenuItem>({
  required String text,
  required Color? textColor,
  bool enabled = true,
  PlutoGridColumnMenuItem? value,
}) {
  return PopupMenuItem<PlutoGridColumnMenuItem>(
    value: value,
    height: 36,
    enabled: enabled,
    child: Text(
      text,
      style: TextStyle(
        color: enabled ? textColor : textColor!.withOpacity(0.5),
        fontSize: 13,
      ),
    ),
  );
}

/// Items in the context menu on the right side of the column
enum PlutoGridColumnMenuItem {
  setFilter,
}
