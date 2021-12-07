import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoDualGridPopup {
  final BuildContext? context;
  final PlutoDualGridProps? gridPropsA;
  final PlutoDualGridProps? gridPropsB;
  final PlutoGridMode? mode;
  final PlutoDualOnSelectedEventCallback? onSelected;
  final PlutoDualGridDisplay display;
  final double? width;
  final double? height;

  PlutoDualGridPopup({
    this.context,
    this.gridPropsA,
    this.gridPropsB,
    this.mode,
    this.onSelected,
    this.display = const PlutoDualGridDisplayRatio(),
    this.width,
    this.height,
  }) {
    open();
  }

  Future<void> open() async {
    final splitBorderRadius = _splitBorderRadius();

    final shape = _getShape(splitBorderRadius);

    final propsA = _applyBorderRadiusToGridProps(
      splitBorderRadius?.elementAt(0),
      gridPropsA,
    );

    final propsB = _applyBorderRadiusToGridProps(
      splitBorderRadius?.elementAt(1),
      gridPropsB,
    );

    PlutoDualOnSelectedEvent? selected =
        await showDialog<PlutoDualOnSelectedEvent>(
            context: context!,
            builder: (BuildContext ctx) {
              return Dialog(
                shape: shape,
                child: LayoutBuilder(
                  builder: (ctx, size) {
                    return Container(
                      width: (width ?? size.maxWidth) +
                          PlutoGridSettings.gridInnerSpacing,
                      height: height ?? size.maxHeight,
                      child: PlutoDualGrid(
                        gridPropsA: propsA,
                        gridPropsB: propsB,
                        mode: mode,
                        onSelected: (PlutoDualOnSelectedEvent event) {
                          Navigator.pop(ctx, event);
                        },
                        display: display,
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

  List<BorderRadius>? _splitBorderRadius() {
    final left = gridPropsA?.configuration?.gridBorderRadius;

    final right = gridPropsB?.configuration?.gridBorderRadius;

    if (left == null && right == null) {
      return null;
    }

    return [
      BorderRadius.only(
        topLeft: left?.resolve(TextDirection.ltr).topLeft ?? Radius.zero,
        bottomLeft: left?.resolve(TextDirection.ltr).bottomLeft ?? Radius.zero,
        topRight: Radius.zero,
        bottomRight: Radius.zero,
      ),
      BorderRadius.only(
        topLeft: Radius.zero,
        bottomLeft: Radius.zero,
        topRight: right?.resolve(TextDirection.ltr).topRight ?? Radius.zero,
        bottomRight:
            right?.resolve(TextDirection.ltr).bottomRight ?? Radius.zero,
      ),
    ];
  }

  ShapeBorder? _getShape(List<BorderRadius>? borderRadius) {
    if (borderRadius == null) {
      return null;
    }

    return RoundedRectangleBorder(
      borderRadius: borderRadius.elementAt(0) + borderRadius.elementAt(1),
    );
  }

  PlutoDualGridProps? _applyBorderRadiusToGridProps(
    BorderRadius? borderRadius,
    PlutoDualGridProps? gridProps,
  ) {
    if (borderRadius == null || gridProps == null) {
      return gridProps;
    }

    return gridProps.copyWith(
      configuration: gridProps.configuration?.copyWith(
        gridBorderRadius: borderRadius,
      ),
    );
  }
}
