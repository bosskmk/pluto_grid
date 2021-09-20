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
  final PlutoGridConfiguration? configuration;

  PlutoDualGridPopup({
    this.context,
    this.gridPropsA,
    this.gridPropsB,
    this.mode,
    this.onSelected,
    this.display = const PlutoDualGridDisplayRatio(),
    this.width,
    this.height,
    this.configuration,
  }) {
    open();
  }

  Future<void> open() async {
    PlutoDualOnSelectedEvent? selected =
        await showDialog<PlutoDualOnSelectedEvent>(
            context: context!,
            builder: (BuildContext ctx) {
              return Dialog(
                child: LayoutBuilder(
                  builder: (ctx, size) {
                    return Container(
                      width: (width ?? size.maxWidth) +
                          (configuration?.settings.gridInnerSpacing ??
                              PlutoGridSettings.defaultGridInnerSpacing),
                      height: height ?? size.maxHeight,
                      child: PlutoDualGrid(
                        gridPropsA: gridPropsA,
                        gridPropsB: gridPropsB,
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
}
