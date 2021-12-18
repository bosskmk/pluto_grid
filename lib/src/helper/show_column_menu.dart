import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

Text _buildTextItem({
  required String text,
  required Color? textColor,
  bool enabled = true,
}) {
  return Text(
    text,
    style: TextStyle(
      color: enabled ? textColor : textColor!.withOpacity(0.5),
      fontSize: 13,
    ),
  );
}

PopupMenuItem<PlutoGridColumnMenuItem> _buildMenuItem<PlutoGridColumnMenuItem>({
  Widget? child,
  bool enabled = true,
  PlutoGridColumnMenuItem? value,
}) {
  return PopupMenuItem<PlutoGridColumnMenuItem>(
    value: value,
    child: child,
    height: 36,
    enabled: enabled,
  );
}

/// Open the context menu on the right side of the column.
Future<PlutoGridColumnMenuItem?>? showColumnMenu({
  BuildContext? context,
  Offset? position,
  PlutoGridStateManager? stateManager,
  PlutoColumn? column,
}) {
  if (position == null) {
    return null;
  }

  final RenderBox overlay =
      Overlay.of(context!)!.context.findRenderObject() as RenderBox;

  final Color? textColor = stateManager!.configuration!.cellTextStyle.color;

  final Color backgroundColor = stateManager.configuration!.menuBackgroundColor;

  final localeText = stateManager.localeText;

  return showMenu<PlutoGridColumnMenuItem>(
    context: context,
    color: backgroundColor,
    position: RelativeRect.fromRect(
        position & const Size(40, 40), Offset.zero & overlay.size),
    items: [
      if (column!.frozen.isFrozen == true)
        _buildMenuItem(
          value: PlutoGridColumnMenuItem.unfreeze,
          child: _buildTextItem(
            text: localeText.unfreezeColumn,
            textColor: textColor,
          ),
        ),
      if (column.frozen.isFrozen != true) ...[
        _buildMenuItem(
          value: PlutoGridColumnMenuItem.freezeToLeft,
          child: _buildTextItem(
            text: localeText.freezeColumnToLeft,
            textColor: textColor,
          ),
        ),
        _buildMenuItem(
          value: PlutoGridColumnMenuItem.freezeToRight,
          child: _buildTextItem(
            text: localeText.freezeColumnToRight,
            textColor: textColor,
          ),
        ),
      ],
      const PopupMenuDivider(),
      _buildMenuItem(
        value: PlutoGridColumnMenuItem.autoFit,
        child: _buildTextItem(
          text: localeText.autoFitColumn,
          textColor: textColor,
        ),
      ),
      if (column.enableHideColumnMenuItem == true)
        _buildMenuItem(
          value: PlutoGridColumnMenuItem.hideColumn,
          child: _buildTextItem(
            text: localeText.hideColumn,
            enabled: stateManager.refColumns!.length > 1,
            textColor: textColor,
          ),
          enabled: stateManager.refColumns!.length > 1,
        ),
      if (column.enableSetColumnsMenuItem == true)
        _buildMenuItem(
          value: PlutoGridColumnMenuItem.setColumns,
          child: _buildTextItem(
            text: localeText.setColumns,
            textColor: textColor,
          ),
        ),
      if (column.enableFilterMenuItem == true) ...[
        const PopupMenuDivider(),
        _buildMenuItem(
          value: PlutoGridColumnMenuItem.setFilter,
          child: _buildTextItem(
            text: localeText.setFilter,
            textColor: textColor,
          ),
        ),
        _buildMenuItem(
          value: PlutoGridColumnMenuItem.resetFilter,
          child: _buildTextItem(
            text: localeText.resetFilter,
            enabled: stateManager.hasFilter,
            textColor: textColor,
          ),
          enabled: stateManager.hasFilter,
        ),
      ],
    ],
  );
}

/// Items in the context menu on the right side of the column
enum PlutoGridColumnMenuItem {
  unfreeze,
  freezeToLeft,
  freezeToRight,
  hideColumn,
  setColumns,
  autoFit,
  setFilter,
  resetFilter,
}
