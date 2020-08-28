part of '../pluto_grid.dart';

class PlutoGridPopup {
  final BuildContext context;
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final PlutoMode mode;
  final PlutoOnLoadedEventCallback onLoaded;
  final void Function(PlutoRow row) onSelectedRow;
  final double width;
  final double height;

  PlutoGridPopup({
    this.context,
    this.columns,
    this.rows,
    this.mode,
    this.onLoaded,
    this.onSelectedRow,
    this.width,
    this.height,
  }) {
    this.open();
  }

  Future<void> open() async {
    PlutoRow selectedRow = await showDialog<PlutoRow>(
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
                    onSelectedRow: (PlutoOnSelectedEvent event) {
                      Navigator.pop(ctx, event.row);
                    },
                  ),
                );
              },
            ),
          );
        });
    if (onSelectedRow != null) {
      onSelectedRow(selectedRow);
    }
  }
}
