import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'mixin_text_cell.dart';

class PlutoImageCell extends StatefulWidget implements AbstractMixinTextCell {
  final PlutoGridStateManager? stateManager;
  final PlutoCell? cell;
  final PlutoColumn? column;

  PlutoImageCell({
    this.stateManager,
    this.cell,
    this.column,
  });

  @override
  _PlutoImageCellState createState() => _PlutoImageCellState();
}

class _PlutoImageCellState extends State<PlutoImageCell> {
  @override
  Widget build(BuildContext context) {
    if (widget.column?.type?.isValid(widget.cell) != true || widget.column?.type is! PlutoColumnTypeImage)
      return Container();

    PlutoColumnTypeImage type = widget.column!.type as PlutoColumnTypeImage;

    Widget content;
    if (widget.cell?.value is Uint8List) {
      content = Image.memory(widget.cell!.value as Uint8List, fit: type.fit ?? BoxFit.cover);
    } else {
      if (type.isAsset) {
        content = Image.asset(widget.cell!.value as String, fit: type.fit ?? BoxFit.cover);
      } else {
        content = Image.network(widget.cell!.value as String, fit: type.fit ?? BoxFit.cover);
      }
    }

    if (type.decoration != null)
      content = Container(decoration: type.decoration, clipBehavior: Clip.hardEdge, child: content);

    if (type.aspect != null) content = AspectRatio(aspectRatio: type.aspect!, child: content);

    return content;
  }
}
