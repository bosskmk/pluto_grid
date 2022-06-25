import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

typedef PlutoDualOnSelectedEventCallback = void Function(
    PlutoDualOnSelectedEvent event);

class PlutoDualGridDivider {
  final bool show;

  final Color backgroundColor;

  final Color indicatorColor;

  final Color draggingColor;

  const PlutoDualGridDivider({
    this.show = true,
    this.backgroundColor = Colors.white,
    this.indicatorColor = const Color(0xFFA1A5AE),
    this.draggingColor = const Color(0xFFDCF5FF),
  });

  const PlutoDualGridDivider.dark({
    this.show = true,
    this.backgroundColor = const Color(0xFF111111),
    this.indicatorColor = const Color(0xFF000000),
    this.draggingColor = const Color(0xFF313131),
  });
}

/// [PlutoDualGrid] can connect the keyboard movement between the two grids
/// by arranging two [PlutoGrid] left and right.
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
  final PlutoDualGridDisplay? display;

  final PlutoDualGridDivider divider;

  const PlutoDualGrid({
    required this.gridPropsA,
    required this.gridPropsB,
    this.mode,
    this.onSelected,
    this.display,
    this.divider = const PlutoDualGridDivider(),
    Key? key,
  }) : super(key: key);

  static const double dividerWidth = 10;

  @override
  PlutoDualGridState createState() => PlutoDualGridState();
}

class PlutoDualGridResizeNotifier extends ChangeNotifier {
  resize() {
    notifyListeners();
  }
}

class PlutoDualGridState extends State<PlutoDualGrid> {
  final PlutoDualGridResizeNotifier resizeNotifier =
      PlutoDualGridResizeNotifier();

  late final PlutoDualGridDisplay display;

  PlutoGridStateManager? _stateManagerA;

  PlutoGridStateManager? _stateManagerB;

  @override
  void initState() {
    super.initState();

    display = widget.display ?? PlutoDualGridDisplayRatio();
  }

  Widget _buildGrid({
    required PlutoDualGridProps props,
    PlutoGridMode? mode,
    double? width,
    bool? isGridA,
  }) {
    return LayoutId(
      id: isGridA == true ? _PlutoDualGridId.gridA : _PlutoDualGridId.gridB,
      child: SizedBox(
        width: width,
        child: PlutoGrid(
          columns: props.columns,
          rows: props.rows,
          columnGroups: props.columnGroups,
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
          key: props.key,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: PlutoDualGridLayoutDelegate(
        notifier: resizeNotifier,
        display: display,
        showDraggableDivider: widget.divider.show,
      ),
      children: [
        _buildGrid(
          props: widget.gridPropsA,
          mode: widget.mode,
          width: 100,
          isGridA: true,
        ),
        if (widget.divider.show == true)
          LayoutId(
            id: _PlutoDualGridId.divider,
            child: PlutoDualGridDividerWidget(
              backgroundColor: widget.divider.backgroundColor,
              indicatorColor: widget.divider.indicatorColor,
              draggingColor: widget.divider.draggingColor,
              dragCallback: (details) {
                final RenderBox object =
                    context.findRenderObject() as RenderBox;

                display.offset = object
                    .globalToLocal(Offset(
                      details.globalPosition.dx,
                      details.globalPosition.dy,
                    ))
                    .dx;

                resizeNotifier.resize();
              },
            ),
          ),
        _buildGrid(
          props: widget.gridPropsB,
          mode: widget.mode,
          width: 100,
          isGridA: false,
        ),
      ],
    );
  }
}

class PlutoDualGridDividerWidget extends StatefulWidget {
  final Color backgroundColor;

  final Color indicatorColor;

  final Color draggingColor;

  final void Function(DragUpdateDetails) dragCallback;

  const PlutoDualGridDividerWidget({
    required this.backgroundColor,
    required this.indicatorColor,
    required this.draggingColor,
    required this.dragCallback,
    Key? key,
  }) : super(key: key);

  @override
  State<PlutoDualGridDividerWidget> createState() =>
      PlutoDualGridDividerWidgetState();
}

class PlutoDualGridDividerWidgetState
    extends State<PlutoDualGridDividerWidget> {
  bool isDragging = false;

  void onHorizontalDragStart(DragStartDetails details) {
    if (isDragging == false) {
      setState(() {
        isDragging = true;
      });
    }
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    widget.dragCallback(details);

    if (isDragging == false) {
      setState(() {
        isDragging = true;
      });
    }
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    setState(() {
      isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (layoutContext, size) {
        return GestureDetector(
          onHorizontalDragStart: onHorizontalDragStart,
          onHorizontalDragUpdate: onHorizontalDragUpdate,
          onHorizontalDragEnd: onHorizontalDragEnd,
          child: ColoredBox(
            color: isDragging ? widget.draggingColor : widget.backgroundColor,
            child: Stack(
              children: [
                Positioned(
                  top: (size.maxHeight / 2) - 18,
                  left: -4,
                  child: Icon(
                    Icons.drag_indicator,
                    color: widget.indicatorColor,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _PlutoDualGridId {
  gridA,
  gridB,
  divider,
}

class PlutoDualGridLayoutDelegate extends MultiChildLayoutDelegate {
  PlutoDualGridLayoutDelegate({
    required ChangeNotifier notifier,
    required this.display,
    required this.showDraggableDivider,
  }) : super(relayout: notifier);

  final PlutoDualGridDisplay display;

  final bool showDraggableDivider;

  @override
  void performLayout(Size size) {
    final BoxConstraints constrains = BoxConstraints(
      maxWidth: size.width,
      maxHeight: size.height,
    );

    final dividerOffset =
        showDraggableDivider ? PlutoDualGrid.dividerWidth / 2 : 0;

    double gridAWidth = showDraggableDivider
        ? display.offset == null
            ? display.gridAWidth(constrains) - dividerOffset
            : display.offset! - dividerOffset
        : display.gridAWidth(constrains) - dividerOffset;

    if (showDraggableDivider) {
      if (gridAWidth < dividerOffset) {
        gridAWidth = 0;
      } else if (gridAWidth > size.width - dividerOffset) {
        gridAWidth = size.width - dividerOffset;
      }
    }

    final gridBWidth = size.width - gridAWidth - dividerOffset;

    if (hasChild(_PlutoDualGridId.gridA)) {
      layoutChild(
        _PlutoDualGridId.gridA,
        BoxConstraints.tight(
          Size(gridAWidth, size.height),
        ),
      );

      positionChild(
        _PlutoDualGridId.gridA,
        const Offset(0, 0),
      );
    }

    if (hasChild(_PlutoDualGridId.divider)) {
      layoutChild(
        _PlutoDualGridId.divider,
        BoxConstraints.tight(
          Size(PlutoDualGrid.dividerWidth, size.height),
        ),
      );

      positionChild(
        _PlutoDualGridId.divider,
        Offset(gridAWidth, 0),
      );
    }

    if (hasChild(_PlutoDualGridId.gridB)) {
      layoutChild(
        _PlutoDualGridId.gridB,
        BoxConstraints.tight(
          Size(gridBWidth, size.height),
        ),
      );

      positionChild(
        _PlutoDualGridId.gridB,
        Offset(gridAWidth + (dividerOffset * 2), 0),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
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

  double? offset;
}

class PlutoDualGridDisplayRatio implements PlutoDualGridDisplay {
  final double ratio;

  PlutoDualGridDisplayRatio({
    this.ratio = 0.5,
  }) : assert(0 < ratio && ratio < 1);

  @override
  double? offset;

  @override
  double gridAWidth(BoxConstraints size) => size.maxWidth * ratio;

  @override
  double gridBWidth(BoxConstraints size) => size.maxWidth * (1 - ratio);
}

class PlutoDualGridDisplayFixedAndExpanded implements PlutoDualGridDisplay {
  final double width;

  PlutoDualGridDisplayFixedAndExpanded({
    this.width = 206.0,
  });

  @override
  double? offset;

  @override
  double gridAWidth(BoxConstraints size) => width;

  @override
  double gridBWidth(BoxConstraints size) => size.maxWidth - width;
}

class PlutoDualGridDisplayExpandedAndFixed implements PlutoDualGridDisplay {
  final double width;

  PlutoDualGridDisplayExpandedAndFixed({
    this.width = 206.0,
  });

  @override
  double? offset;

  @override
  double gridAWidth(BoxConstraints size) => size.maxWidth - width;

  @override
  double gridBWidth(BoxConstraints size) => width;
}

class PlutoDualGridProps {
  final List<PlutoColumn> columns;

  final List<PlutoRow> rows;

  final List<PlutoColumnGroup>? columnGroups;

  final PlutoOnLoadedEventCallback? onLoaded;

  final PlutoOnChangedEventCallback? onChanged;

  final CreateHeaderCallBack? createHeader;

  final CreateFooterCallBack? createFooter;

  final PlutoGridConfiguration configuration;

  const PlutoDualGridProps({
    required this.columns,
    required this.rows,
    this.columnGroups,
    this.onLoaded,
    this.onChanged,
    this.createHeader,
    this.createFooter,
    this.configuration = const PlutoGridConfiguration(),
    this.key,
  });

  final Key? key;

  PlutoDualGridProps copyWith({
    List<PlutoColumn>? columns,
    List<PlutoRow>? rows,
    List<PlutoColumnGroup>? columnGroups,
    PlutoOnLoadedEventCallback? onLoaded,
    PlutoOnChangedEventCallback? onChanged,
    CreateHeaderCallBack? createHeader,
    CreateFooterCallBack? createFooter,
    PlutoGridConfiguration? configuration,
    Key? key,
  }) {
    return PlutoDualGridProps(
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      columnGroups: columnGroups ?? this.columnGroups,
      onLoaded: onLoaded ?? this.onLoaded,
      onChanged: onChanged ?? this.onChanged,
      createHeader: createHeader ?? this.createHeader,
      createFooter: createFooter ?? this.createFooter,
      configuration: configuration ?? this.configuration,
      key: key ?? this.key,
    );
  }
}
