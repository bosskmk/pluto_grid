import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBaseColumnFooter extends PlutoStatefulWidget
    implements PlutoVisibilityLayoutChild {
  final PlutoGridStateManager stateManager;

  final PlutoColumn column;

  PlutoBaseColumnFooter({
    required this.stateManager,
    required this.column,
  }) : super(key: column.key);

  @override
  PlutoBaseColumnFooterState createState() => PlutoBaseColumnFooterState();

  @override
  double get width => column.width;

  @override
  double get startPosition => column.startPosition;

  @override
  bool get keepAlive => true;
}

class PlutoBaseColumnFooterState
    extends PlutoStateWithChange<PlutoBaseColumnFooter> {
  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    var renderer = widget.column.footerRenderer;
    return Container(
      padding: widget.column.footerPadding ??
          widget.stateManager.style.defaultColumnFooterPadding,
      decoration: BoxDecoration(
        color: widget.column.backgroundColor,
        border: BorderDirectional(
            end: widget.stateManager.style.enableColumnBorderVertical
                ? BorderSide(
                    color: widget.stateManager.style.borderColor, width: 1.0)
                : BorderSide.none,
            bottom: widget.stateManager.style.enableColumnBorderVertical
                ? BorderSide(
                    color: widget.stateManager.style.borderColor, width: 1.0)
                : BorderSide.none),
      ),
      child: renderer != null ? renderer(context) : const SizedBox(),
    );
  }
}
