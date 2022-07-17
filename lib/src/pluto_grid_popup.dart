import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// [PlutoGridPopup] calls [PlutoGrid] in the form of a popup.
class PlutoGridPopup {
  final BuildContext context;

  final List<PlutoColumn> columns;

  final List<PlutoRow> rows;

  final List<PlutoColumnGroup>? columnGroups;

  final PlutoOnLoadedEventCallback? onLoaded;

  final PlutoOnChangedEventCallback? onChanged;

  final PlutoOnSelectedEventCallback? onSelected;

  final PlutoOnSortedEventCallback? onSorted;

  final PlutoOnRowCheckedEventCallback? onRowChecked;

  final PlutoOnRowDoubleTapEventCallback? onRowDoubleTap;

  final PlutoOnRowSecondaryTapEventCallback? onRowSecondaryTap;

  final PlutoOnRowsMovedEventCallback? onRowsMoved;

  final CreateHeaderCallBack? createHeader;

  final CreateFooterCallBack? createFooter;

  final PlutoRowColorCallback? rowColorCallback;

  final PlutoColumnMenuDelegate? columnMenuDelegate;

  final PlutoGridConfiguration? configuration;

  final PlutoGridMode? mode;

  final double? width;

  final double? height;

  PlutoGridPopup({
    required this.context,
    required this.columns,
    required this.rows,
    this.columnGroups,
    this.onLoaded,
    this.onChanged,
    this.onSelected,
    this.onSorted,
    this.onRowChecked,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.onRowsMoved,
    this.createHeader,
    this.createFooter,
    this.rowColorCallback,
    this.columnMenuDelegate,
    this.configuration,
    this.mode,
    this.width,
    this.height,
  }) {
    open();
  }

  Future<void> open() async {
    PlutoGridOnSelectedEvent? selected =
        await showDialog<PlutoGridOnSelectedEvent>(
            context: context,
            builder: (BuildContext ctx) {
              return Dialog(
                shape: configuration?.style.gridBorderRadius != null
                    ? RoundedRectangleBorder(
                        borderRadius: configuration!.style.gridBorderRadius,
                      )
                    : null,
                child: LayoutBuilder(
                  builder: (ctx, size) {
                    return SizedBox(
                      width: (width ?? size.maxWidth) +
                          PlutoGridSettings.gridInnerSpacing,
                      height: height ?? size.maxHeight,
                      child: Directionality(
                        textDirection: Directionality.of(context),
                        child: PlutoGrid(
                          columns: columns,
                          rows: rows,
                          columnGroups: columnGroups,
                          onLoaded: onLoaded,
                          onChanged: onChanged,
                          onSelected: (PlutoGridOnSelectedEvent event) {
                            Navigator.pop(ctx, event);
                          },
                          onSorted: onSorted,
                          onRowChecked: onRowChecked,
                          onRowDoubleTap: onRowDoubleTap,
                          onRowSecondaryTap: onRowSecondaryTap,
                          onRowsMoved: onRowsMoved,
                          createHeader: createHeader,
                          createFooter: createFooter,
                          rowColorCallback: rowColorCallback,
                          columnMenuDelegate: columnMenuDelegate,
                          configuration: configuration,
                          mode: mode,
                        ),
                      ),
                    );
                  },
                ),
              );
            });
    if (onSelected != null && selected != null) {
      onSelected!(selected);
    }
  }
}
