part of '../../pluto_grid.dart';

typedef PlutoOnChangedEventCallback = void Function(PlutoOnChangedEvent event);

/// Caution
///
/// [columnIdx] and [rowIdx] are values in the currently displayed state.
class PlutoOnChangedEvent {
  final int columnIdx;
  final PlutoColumn column;
  final int rowIdx;
  final PlutoRow row;
  final dynamic value;
  final dynamic oldValue;

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
    out += 'ColumnIndex : $columnIdx, RowIndex : $rowIdx\n';
    out += '::: oldValue : $oldValue\n';
    out += '::: newValue : $value';
    return out;
  }
}
