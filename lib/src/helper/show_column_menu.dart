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
    height: 36,
    enabled: enabled,
    child: child,
  );
}

/// Open the context menu on the right side of the column.
Future<PlutoGridColumnMenuItem?>? showColumnMenu({
  required BuildContext context,
  required Offset position,
  required PlutoGridStateManager stateManager,
  required PlutoColumn column,
}) {
  final RenderBox overlay =
      Overlay.of(context)!.context.findRenderObject() as RenderBox;

  final Color textColor = stateManager.style.cellTextStyle.color!;

  final Color disableTextColor = textColor.withOpacity(0.5);

  final bool enoughFrozenColumnsWidth = stateManager.enoughFrozenColumnsWidth(
    stateManager.maxWidth! - column.width,
  );

  final Color backgroundColor =
      stateManager.configuration!.style.menuBackgroundColor;

  final localeText = stateManager.localeText;

  return showMenu<PlutoGridColumnMenuItem>(
    context: context,
    color: backgroundColor,
    position: RelativeRect.fromRect(
        position & const Size(40, 40), Offset.zero & overlay.size),
    items: [
      if (column.frozen.isFrozen == true)
        _buildMenuItem(
          value: PlutoGridColumnMenuItem.unfreeze,
          child: _buildTextItem(
            text: localeText.unfreezeColumn,
            textColor: textColor,
          ),
        ),
      if (column.frozen.isFrozen != true) ...[
        _buildMenuItem(
          value: PlutoGridColumnMenuItem.freezeToStart,
          enabled: enoughFrozenColumnsWidth,
          child: _buildTextItem(
            text: localeText.freezeColumnToStart,
            textColor: enoughFrozenColumnsWidth ? textColor : disableTextColor,
          ),
        ),
        _buildMenuItem(
          value: PlutoGridColumnMenuItem.freezeToEnd,
          enabled: enoughFrozenColumnsWidth,
          child: _buildTextItem(
            text: localeText.freezeColumnToEnd,
            textColor: enoughFrozenColumnsWidth ? textColor : disableTextColor,
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
            enabled: stateManager.refColumns.length > 1,
            textColor: textColor,
          ),
          enabled: stateManager.refColumns.length > 1,
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
  freezeToStart,
  freezeToEnd,
  hideColumn,
  setColumns,
  autoFit,
  setFilter,
  resetFilter,
}
