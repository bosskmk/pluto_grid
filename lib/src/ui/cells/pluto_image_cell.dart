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
    if (widget.column?.type is! PlutoColumnTypeImage) return Container();

    PlutoColumnTypeImage type = widget.column!.type as PlutoColumnTypeImage;

    Widget content;
    if (widget.cell?.value is Future<Uint8List?> || widget.cell?.value is Future<Uint8List>) {
      Future<Uint8List?> future;
      if (widget.cell?.value is Future<Uint8List?>) {
        future = widget.cell?.value as Future<Uint8List?>;
      } else {
        future = widget.cell?.value as Future<Uint8List>;
      }

      content = FutureBuilder<Uint8List?>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Image.memory(snapshot.data!, fit: type.fit ?? BoxFit.cover);
          } else {
            return ColoredBox(color: Colors.grey.shade100);
          }
        },
      );
    } else if (widget.cell?.value is Future<String?> || widget.cell?.value is Future<String>) {
      Future<String?> future;
      if (widget.cell?.value is Future<String?>) {
        future = widget.cell?.value as Future<String?>;
      } else {
        future = widget.cell?.value as Future<String>;
      }

      content = FutureBuilder<String?>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            if (type.isAsset) {
              return Image.asset(snapshot.data!, fit: type.fit ?? BoxFit.cover);
            } else {
              return Image.network(snapshot.data!, fit: type.fit ?? BoxFit.cover);
            }
          } else {
            return ColoredBox(color: Colors.grey.shade100);
          }
        },
      );
    } else if (widget.cell?.value is Uint8List) {
      content = Image.memory(widget.cell!.value as Uint8List, fit: type.fit ?? BoxFit.cover);
    } else if (widget.cell?.value is String) {
      if (type.isAsset) {
        content = Image.asset(widget.cell!.value as String, fit: type.fit ?? BoxFit.cover);
      } else {
        content = Image.network(widget.cell!.value as String, fit: type.fit ?? BoxFit.cover);
      }
    } else {
      content = Container();
    }

    if (type.decoration != null)
      content = Container(decoration: type.decoration, clipBehavior: Clip.hardEdge, child: content);

    if (type.aspect != null) content = AspectRatio(aspectRatio: type.aspect!, child: content);

    return content;
  }
}
