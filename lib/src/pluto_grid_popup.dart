import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridPopup {
  final BuildContext? context;
  final List<PlutoColumn>? columns;
  final List<PlutoRow?>? rows;
  final PlutoGridMode? mode;
  final PlutoOnLoadedEventCallback? onLoaded;
  final PlutoOnChangedEventCallback? onChanged;
  final PlutoOnSelectedEventCallback? onSelected;
  final double? width;
  final double? height;
  final CreateHeaderCallBack? createHeader;
  final CreateFooterCallBack? createFooter;
  final PlutoGridConfiguration? configuration;

  PlutoGridPopup({
    this.context,
    this.columns,
    this.rows,
    this.mode,
    this.onLoaded,
    this.onChanged,
    this.onSelected,
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
            context: context!,
            builder: (BuildContext ctx) {
              return Dialog(
                child: LayoutBuilder(
                  builder: (ctx, size) {
                    return Container(
                      width: (width ?? size.maxWidth) +
                          (configuration?.settings.gridInnerSpacing ??
                              PlutoGridSettings.defaultGridInnerSpacing),
                      height: height ?? size.maxHeight,
                      child: PlutoGrid(
                        columns: columns,
                        rows: rows,
                        mode: mode,
                        onLoaded: onLoaded,
                        onChanged: onChanged,
                        onSelected: (PlutoGridOnSelectedEvent event) {
                          Navigator.pop(ctx, event);
                        },
                        createHeader: createHeader,
                        createFooter: createFooter,
                        configuration: configuration,
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
