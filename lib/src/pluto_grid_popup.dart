import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

/// [PlutoGridPopup] calls [PlutoGrid] in the form of a popup.
class PlutoGridPopup {
  final BuildContext context;

  /// {@macro pluto_grid_property_columns}
  final List<PlutoColumn> columns;

  /// {@macro pluto_grid_property_rows}
  final List<PlutoRow> rows;

  /// {@macro pluto_grid_property_columnGroups}
  final List<PlutoColumnGroup>? columnGroups;

  /// {@macro pluto_grid_property_onLoaded}
  final PlutoOnLoadedEventCallback? onLoaded;

  /// {@macro pluto_grid_property_onChanged}
  final PlutoOnChangedEventCallback? onChanged;

  /// {@macro pluto_grid_property_onSelected}
  final PlutoOnSelectedEventCallback? onSelected;

  /// {@macro pluto_grid_property_onSorted}
  final PlutoOnSortedEventCallback? onSorted;

  /// {@macro pluto_grid_property_onRowChecked}
  final PlutoOnRowCheckedEventCallback? onRowChecked;

  /// {@macro pluto_grid_property_onRowDoubleTap}
  final PlutoOnRowDoubleTapEventCallback? onRowDoubleTap;

  /// {@macro pluto_grid_property_onRowSecondaryTap}
  final PlutoOnRowSecondaryTapEventCallback? onRowSecondaryTap;

  /// {@macro pluto_grid_property_onRowsMoved}
  final PlutoOnRowsMovedEventCallback? onRowsMoved;

  /// {@macro pluto_grid_property_createHeader}
  final CreateHeaderCallBack? createHeader;

  /// {@macro pluto_grid_property_createFooter}
  final CreateFooterCallBack? createFooter;

  /// {@macro pluto_grid_property_rowColorCallback}
  final PlutoRowColorCallback? rowColorCallback;

  /// {@macro pluto_grid_property_columnMenuDelegate}
  final PlutoColumnMenuDelegate? columnMenuDelegate;

  /// {@macro pluto_grid_property_configuration}
  final PlutoGridConfiguration? configuration;

  /// Execution mode of [PlutoGrid].
  ///
  /// [PlutoGridMode.normal]
  /// {@macro pluto_grid_mode_normal}
  ///
  /// [PlutoGridMode.select], [PlutoGridMode.selectWithOneTap]
  /// {@macro pluto_grid_mode_select}
  ///
  /// [PlutoGridMode.popup]
  /// {@macro pluto_grid_mode_popup}
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
