part of pluto_grid;

typedef PlutoOnChangedEventCallback = void Function(PlutoOnChangedEvent event);

class PlutoOnChangedEvent {
  final int columnIdx;
  final PlutoColumn column;
  final int rowIdx;
  final PlutoRow row;
  final String value;
  final String oldValue;

  PlutoOnChangedEvent({
    this.columnIdx,
    this.column,
    this.rowIdx,
    this.row,
    this.value,
    this.oldValue,
  });

  @override
  String toString() {
    String out = '[PlutoOnChangedEvent] ';
    out += 'ColumnIndex : ${this.columnIdx}, RowIndex : ${this.rowIdx}\n';
    out += '::: oldValue : ${this.oldValue}\n';
    out += '::: newValue : ${this.value}';
    return out;
  }
}
