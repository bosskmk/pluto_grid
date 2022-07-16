import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// [PlutoGridPopup] calls [PlutoGrid] in the form of a popup.
class PlutoGridPopup {
  final BuildContext context;

  final List<PlutoColumn> columns;

  final List<PlutoRow> rows;

  final PlutoGridMode? mode;

  final PlutoOnLoadedEventCallback? onLoaded;

  final PlutoOnChangedEventCallback? onChanged;

  final PlutoOnSelectedEventCallback? onSelected;

  final PlutoOnSortedEventCallback? onSorted;

  final PlutoOnRowCheckedEventCallback? onRowChecked;
  final PlutoOnRowsMovedEventCallback? onRowsMoved;
  final PlutoOnRowDoubleTapEventCallback? onRowDoubleTap;
  final PlutoOnRowSecondaryTapEventCallback? onRowSecondaryTap;
  final double? width;

  final double? height;

  final CreateHeaderCallBack? createHeader;

  final CreateFooterCallBack? createFooter;

  final PlutoGridConfiguration? configuration;

  PlutoGridPopup({
    required this.context,
    required this.columns,
    required this.rows,
    this.mode,
    this.onLoaded,
    this.onChanged,
    this.onSelected,
    this.onSorted,
    this.onRowChecked,
    this.onRowsMoved,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.width,
    this.height,
    this.createHeader,
    this.createFooter,
    this.configuration,
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
                          mode: mode,
                          onLoaded: onLoaded,
                          onChanged: onChanged,
                          onSelected: (PlutoGridOnSelectedEvent event) {
                            Navigator.pop(ctx, event);
                          },
                          onSorted: onSorted,
                          onRowChecked: onRowChecked,
                          onRowsMoved: onRowsMoved,
                          onRowDoubleTap: onRowDoubleTap,
                          onRowSecondaryTap: onRowSecondaryTap,
                          createHeader: createHeader,
                          createFooter: createFooter,
                          configuration: configuration,
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
