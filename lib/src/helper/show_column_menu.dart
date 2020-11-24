part of '../../pluto_grid.dart';

enum PlutoGridColumnMenuItem {
  unfreeze,
  freezeToLeft,
  freezeToRight,
  autoFit,
}

Future<PlutoGridColumnMenuItem> showColumnMenu({
  BuildContext context,
  Offset position,
  PlutoStateManager stateManager,
  PlutoColumn column,
}) {
  if (position == null) {
    return null;
  }

  final RenderBox overlay = Overlay.of(context).context.findRenderObject();

  final Color textColor = stateManager.configuration.cellTextStyle.color;

  final Color backgroundColor = stateManager.configuration.menuBackgroundColor;

  final buildTextItem = (String text) {
    return Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: 13,
      ),
    );
  };

  final buildMenuItem = <PlutoGridColumnMenuItem>({
    PlutoGridColumnMenuItem value,
    Widget child,
  }) {
    return PopupMenuItem<PlutoGridColumnMenuItem>(
      value: value,
      child: child,
      height: 36,
    );
  };

  final localeText = stateManager.localeText;

  return showMenu<PlutoGridColumnMenuItem>(
    context: context,
    color: backgroundColor,
    position: RelativeRect.fromRect(
        position & const Size(40, 40), Offset.zero & overlay.size),
    items: [
      if (column.frozen.isFrozen == true)
        buildMenuItem(
          value: PlutoGridColumnMenuItem.unfreeze,
          child: buildTextItem(localeText.unfreezeColumn),
        ),
      if (column.frozen.isFrozen != true) ...[
        buildMenuItem(
          value: PlutoGridColumnMenuItem.freezeToLeft,
          child: buildTextItem(localeText.freezeColumnToLeft),
        ),
        buildMenuItem(
          value: PlutoGridColumnMenuItem.freezeToRight,
          child: buildTextItem(localeText.freezeColumnToRight),
        ),
      ],
      const PopupMenuDivider(),
      buildMenuItem(
        value: PlutoGridColumnMenuItem.autoFit,
        child: buildTextItem(localeText.autoFitColumn),
      ),
    ],
  );
}
