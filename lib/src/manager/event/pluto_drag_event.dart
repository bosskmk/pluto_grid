part of '../../../pluto_grid.dart';

/// Event : Dragging a [PlutoDragItemType].
class PlutoDragEvent<T> extends PlutoEvent {
  final Offset offset;
  final PlutoDragType dragType;
  final PlutoDragItemType itemType;
  final T dragData;

  PlutoDragEvent({
    this.offset,
    this.dragType,
    this.itemType,
    this.dragData,
  }) : assert(itemType.isRows && dragData is List<PlutoRow>);
}

enum PlutoDragType {
  Start,
  Update,
  End,
}

extension PlutoDragTypeExtension on PlutoDragType {
  bool get isStart => this == PlutoDragType.Start;

  bool get isUpdate => this == PlutoDragType.Update;

  bool get isEnd => this == PlutoDragType.End;
}

enum PlutoDragItemType {
  Rows,
}

extension PlutoDragItemExtension on PlutoDragItemType {
  bool get isRows => this == PlutoDragItemType.Rows;
}