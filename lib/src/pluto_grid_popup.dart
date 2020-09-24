part of '../pluto_grid.dart';

class PlutoGridPopup {
  final BuildContext context;
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final PlutoMode mode;
  final PlutoOnLoadedEventCallback onLoaded;
  final PlutoOnSelectedEventCallback onSelected;
  final double width;
  final double height;
  final CreateHeaderCallBack createHeader;
  final CreateFooterCallBack createFooter;
  final PlutoConfiguration configuration;

  PlutoGridPopup({
    this.context,
    this.columns,
    this.rows,
    this.mode,
    this.onLoaded,
    this.onSelected,
    this.width,
    this.height,
    this.createHeader,
    this.createFooter,
    this.configuration,
  }) {
    this.open();
  }

  Future<void> open() async {
    PlutoOnSelectedEvent selected = await showDialog<PlutoOnSelectedEvent>(
        context: context,
        builder: (BuildContext ctx) {
          return Dialog(
            child: LayoutBuilder(
              builder: (ctx, size) {
                return Container(
                  width: (width ?? size.maxWidth) +
                      PlutoDefaultSettings.gridInnerSpacing,
                  height: height ?? size.maxHeight,
                  child: PlutoGrid.popup(
                    columns: columns,
                    rows: rows,
                    mode: mode,
                    onLoaded: onLoaded,
                    onSelected: (PlutoOnSelectedEvent event) {
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
    if (onSelected != null) {
      onSelected(selected);
    }
  }
}
