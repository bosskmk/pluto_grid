import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

typedef PlutoDualOnSelectedEventCallback = void Function(
    PlutoDualOnSelectedEvent event);

class PlutoDualGrid extends StatefulWidget {
  final PlutoDualGridProps gridPropsA;

  final PlutoDualGridProps gridPropsB;

  final PlutoGridMode? mode;

  final PlutoDualOnSelectedEventCallback? onSelected;

  /// [PlutoDualGridDisplayRatio]
  /// Set the width of the two grids by specifying the ratio of the left grid.
  /// 0.5 is 5(left grid):5(right grid).
  /// 0.8 is 8(left grid):2(right grid).
  ///
  /// [PlutoDualGridDisplayFixedAndExpanded]
  /// Fix the width of the left grid.
  ///
  /// [PlutoDualGridDisplayExpandedAndFixed]
  /// Fix the width of the right grid.
  final PlutoDualGridDisplay display;

  const PlutoDualGrid({
    required this.gridPropsA,
    required this.gridPropsB,
    this.mode,
    this.onSelected,
    this.display = const PlutoDualGridDisplayRatio(),
    Key? key,
  }) : super(key: key);

  @override
  _PlutoDualGridState createState() => _PlutoDualGridState();
}

class _PlutoDualGridState extends State<PlutoDualGrid> {
  PlutoGridStateManager? _stateManagerA;

  PlutoGridStateManager? _stateManagerB;

  Widget _buildGrid({
    required PlutoDualGridProps props,
    PlutoGridMode? mode,
    double? width,
    bool? isGridA,
  }) {
    return SizedBox(
      width: width,
      child: PlutoGrid(
        columns: props.columns,
        rows: props.rows,
        mode: mode,
        onLoaded: (PlutoGridOnLoadedEvent onLoadedEvent) {
          if (isGridA!) {
            _stateManagerA = onLoadedEvent.stateManager;
          } else {
            _stateManagerB = onLoadedEvent.stateManager;
          }

          onLoadedEvent.stateManager.eventManager!
              .listener((PlutoGridEvent plutoEvent) {
            if (plutoEvent is PlutoGridCannotMoveCurrentCellEvent) {
              if (isGridA == true && plutoEvent.direction.isRight) {
                _stateManagerA!.setKeepFocus(false);
                _stateManagerB!.setKeepFocus(true);
              } else if (isGridA != true && plutoEvent.direction.isLeft) {
                _stateManagerA!.setKeepFocus(true);
                _stateManagerB!.setKeepFocus(false);
              }
            }
          });

          if (props.onLoaded != null) {
            props.onLoaded!(onLoadedEvent);
          }
        },
        onChanged: props.onChanged,
        onSelected: (PlutoGridOnSelectedEvent onSelectedEvent) {
          if (onSelectedEvent.row == null || onSelectedEvent.cell == null) {
            widget.onSelected!(
              PlutoDualOnSelectedEvent(
                gridA: null,
                gridB: null,
              ),
            );
          } else {
            widget.onSelected!(
              PlutoDualOnSelectedEvent(
                gridA: PlutoGridOnSelectedEvent(
                  row: _stateManagerA!.currentRow,
                  rowIdx: _stateManagerA!.currentRowIdx,
                  cell: _stateManagerA!.currentCell,
                ),
                gridB: PlutoGridOnSelectedEvent(
                  row: _stateManagerB!.currentRow,
                  rowIdx: _stateManagerB!.currentRowIdx,
                  cell: _stateManagerB!.currentCell,
                ),
              ),
            );
          }
        },
        createHeader: props.createHeader,
        createFooter: props.createFooter,
        configuration: props.configuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, size) {
      return Row(
        children: [
          _buildGrid(
            props: widget.gridPropsA,
            mode: widget.mode,
            width: widget.display.gridAWidth(size),
            isGridA: true,
          ),
          _buildGrid(
            props: widget.gridPropsB,
            mode: widget.mode,
            width: widget.display.gridBWidth(size),
            isGridA: false,
          ),
        ],
      );
    });
  }
}

class PlutoDualOnSelectedEvent {
  PlutoGridOnSelectedEvent? gridA;
  PlutoGridOnSelectedEvent? gridB;

  PlutoDualOnSelectedEvent({
    this.gridA,
    this.gridB,
  });
}

abstract class PlutoDualGridDisplay {
  double gridAWidth(BoxConstraints size);

  double gridBWidth(BoxConstraints size);
}

class PlutoDualGridDisplayRatio implements PlutoDualGridDisplay {
  final double ratio;

  const PlutoDualGridDisplayRatio({
    this.ratio = 0.5,
  }) : assert(0 < ratio && ratio < 1);

  @override
  double gridAWidth(BoxConstraints size) => size.maxWidth * ratio;

  @override
  double gridBWidth(BoxConstraints size) => size.maxWidth * (1 - ratio);
}

class PlutoDualGridDisplayFixedAndExpanded implements PlutoDualGridDisplay {
  final double width;

  const PlutoDualGridDisplayFixedAndExpanded({
    this.width = 206.0,
  });

  @override
  double gridAWidth(BoxConstraints size) => width;

  @override
  double gridBWidth(BoxConstraints size) => size.maxWidth - width;
}

class PlutoDualGridDisplayExpandedAndFixed implements PlutoDualGridDisplay {
  final double width;

  const PlutoDualGridDisplayExpandedAndFixed({
    this.width = 206.0,
  });

  @override
  double gridAWidth(BoxConstraints size) => size.maxWidth - width;

  @override
  double gridBWidth(BoxConstraints size) => width;
}

class PlutoDualGridProps {
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final PlutoOnLoadedEventCallback? onLoaded;
  final PlutoOnChangedEventCallback? onChanged;
  final CreateHeaderCallBack? createHeader;
  final CreateFooterCallBack? createFooter;
  final PlutoGridConfiguration? configuration;

  PlutoDualGridProps({
    required this.columns,
    required this.rows,
    this.onLoaded,
    this.onChanged,
    this.createHeader,
    this.createFooter,
    this.configuration,
  });

  PlutoDualGridProps copyWith({
    List<PlutoColumn>? columns,
    List<PlutoRow>? rows,
    PlutoOnLoadedEventCallback? onLoaded,
    PlutoOnChangedEventCallback? onChanged,
    CreateHeaderCallBack? createHeader,
    CreateFooterCallBack? createFooter,
    PlutoGridConfiguration? configuration,
  }) {
    return PlutoDualGridProps(
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      onLoaded: onLoaded ?? this.onLoaded,
      onChanged: onChanged ?? this.onChanged,
      createHeader: createHeader ?? this.createHeader,
      createFooter: createFooter ?? this.createFooter,
      configuration: configuration ?? this.configuration,
    );
  }
}
