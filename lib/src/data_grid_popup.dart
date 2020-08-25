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
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select'),
            children: [
              Padding(
                padding: EdgeInsets.all(5),
                child: Container(
                  width: width ?? 500,
                  height: height ?? 600,
                  child: PlutoGrid.popup(
                    columns: columns,
                    rows: rows,
                    mode: mode,
                    onLoaded: onLoaded,
                    onSelectedRow: (PlutoOnSelectedEvent event) {
                      Navigator.pop(context, event.row);
                    },
                  ),
                ),
              ),
            ],
          );
        });
    if (onSelectedRow != null) {
      onSelectedRow(selectedRow);
    }
  }
}
