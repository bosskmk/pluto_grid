import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoColumnTitle extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  final PlutoColumn column;

  late final double height;

  PlutoColumnTitle({
    required this.stateManager,
    required this.column,
    double? height,
  })  : height = height ?? stateManager.columnHeight,
        super(key: ValueKey('column_title_${column.key}'));

  @override
  _PlutoColumnTitleState createState() => _PlutoColumnTitleState();
}

abstract class _PlutoColumnTitleStateWithChange
    extends PlutoStateWithChange<PlutoColumnTitle> {
  PlutoColumnSort? _sort;

  @override
  void onChange() {
    resetState((update) {
      _sort = update<PlutoColumnSort?>(_sort, widget.column.sort);
    });
  }
}

class _PlutoColumnTitleState extends _PlutoColumnTitleStateWithChange {
  late Offset _columnLeftPosition;

  late Offset _columnRightPosition;

  bool _isPointMoving = false;

  void _showContextMenu(BuildContext context, Offset position) async {
    final PlutoGridColumnMenuItem? selectedMenu = await showColumnMenu(
      context: context,
      position: position,
      stateManager: widget.stateManager,
      column: widget.column,
    );

    switch (selectedMenu) {
      case PlutoGridColumnMenuItem.unfreeze:
        widget.stateManager
            .toggleFrozenColumn(widget.column.key, PlutoColumnFrozen.none);
        break;
      case PlutoGridColumnMenuItem.freezeToLeft:
        widget.stateManager
            .toggleFrozenColumn(widget.column.key, PlutoColumnFrozen.left);
        break;
      case PlutoGridColumnMenuItem.freezeToRight:
        widget.stateManager
            .toggleFrozenColumn(widget.column.key, PlutoColumnFrozen.right);
        break;
      case PlutoGridColumnMenuItem.autoFit:
        widget.stateManager.autoFitColumn(context, widget.column);
        break;
      case PlutoGridColumnMenuItem.hideColumn:
        widget.stateManager.hideColumn(widget.column.key, true);
        break;
      case PlutoGridColumnMenuItem.setColumns:
        widget.stateManager.showSetColumnsPopup(context);
        break;
      case PlutoGridColumnMenuItem.setFilter:
        widget.stateManager.showFilterPopup(
          context,
          calledColumn: widget.column,
        );
        break;
      case PlutoGridColumnMenuItem.resetFilter:
        widget.stateManager.setFilter(null);
        break;
      default:
        break;
    }
  }

  void _handleOnPointDown(PointerDownEvent event) {
    _isPointMoving = false;

    _columnRightPosition = event.position;
    _columnLeftPosition = _columnRightPosition - Offset(widget.column.width, 0);
  }

  void _handleOnPointMove(PointerMoveEvent event) {
    _isPointMoving = _columnRightPosition - event.position != Offset.zero;

    if (_isPointMoving &&
        _columnLeftPosition.dx + widget.column.minWidth > event.position.dx) {
      return;
    }

    final moveOffset = event.position.dx - _columnRightPosition.dx;

    widget.stateManager.resizeColumn(
      widget.column,
      moveOffset,
      checkScroll: false,
    );

    widget.stateManager.scrollByDirection(
      PlutoMoveDirection.right,
      widget.stateManager.isInvalidHorizontalScroll
          ? widget.stateManager.scroll!.maxScrollHorizontal
          : widget.stateManager.scroll!.horizontal!.offset,
    );

    _columnRightPosition = event.position;
  }

  void _handleOnPointUp(PointerUpEvent event) {
    if (_isPointMoving) {
      widget.stateManager.updateCorrectScroll();
    } else if (mounted && widget.column.enableContextMenu) {
      _showContextMenu(context, event.position);
    }

    _isPointMoving = false;
  }

  @override
  Widget build(BuildContext context) {
    final _showContextIcon = widget.column.enableContextMenu ||
        widget.column.enableDropToResize ||
        !_sort!.isNone;

    final _enableGesture =
        widget.column.enableContextMenu || widget.column.enableDropToResize;

    final _columnWidget = _BuildSortableWidget(
      stateManager: widget.stateManager,
      column: widget.column,
      child: _BuildColumnWidget(
        stateManager: widget.stateManager,
        column: widget.column,
        height: widget.height,
      ),
    );

    final _contextMenuIcon = Container(
      height: widget.height,
      alignment: Alignment.center,
      child: IconButton(
        icon: PlutoGridColumnIcon(
          sort: _sort,
          color: widget.stateManager.configuration!.iconColor,
          icon:
              widget.column.enableContextMenu ? Icons.dehaze : Icons.code_sharp,
          descendingIcon: widget.stateManager.configuration!.descendingIcon,
        ),
        iconSize: widget.stateManager.configuration!.iconSize,
        mouseCursor: _enableGesture
            ? SystemMouseCursors.resizeLeftRight
            : SystemMouseCursors.basic,
        onPressed: null,
      ),
    );

    return Stack(
      children: [
        Positioned(
          child: widget.column.enableColumnDrag
              ? _BuildDraggableWidget(
                  stateManager: widget.stateManager,
                  column: widget.column,
                  child: _columnWidget,
                )
              : _columnWidget,
        ),
        if (_showContextIcon)
          Positioned(
            right: -3,
            child: _enableGesture
                ? Listener(
                    onPointerDown: _handleOnPointDown,
                    onPointerMove: _handleOnPointMove,
                    onPointerUp: _handleOnPointUp,
                    child: _contextMenuIcon,
                  )
                : _contextMenuIcon,
          ),
      ],
    );
  }
}

class PlutoGridColumnIcon extends StatelessWidget {
  final PlutoColumnSort? sort;

  final Color color;

  final IconData icon;

  final Icon descendingIcon;

  const PlutoGridColumnIcon({
    this.sort,
    this.color = Colors.black26,
    this.icon = Icons.dehaze,
    Key? key,
    this.descendingIcon = const Icon(Icons.sort),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (sort) {
      case PlutoColumnSort.ascending:
        return Transform.rotate(
          angle: 90 * pi / 90,
          child: descendingIcon,
        );
      case PlutoColumnSort.descending:
        return descendingIcon;
      default:
        return Icon(
          icon,
          color: color,
        );
    }
  }
}

class _BuildDraggableWidget extends StatelessWidget {
  final PlutoGridStateManager stateManager;
  final PlutoColumn column;
  final Widget child;

  const _BuildDraggableWidget({
    required this.stateManager,
    required this.column,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<PlutoColumn>(
      data: column,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: PlutoShadowContainer(
          alignment: column.titleTextAlign.alignmentValue,
          width: PlutoGridSettings.minColumnWidth,
          height: stateManager.columnHeight,
          backgroundColor: stateManager.configuration!.gridBackgroundColor,
          borderColor: stateManager.configuration!.gridBorderColor,
          child: Text(
            column.title,
            style: stateManager.configuration!.columnTextStyle.copyWith(
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ),
      child: child,
    );
  }
}

class _BuildSortableWidget extends StatelessWidget {
  final PlutoGridStateManager? stateManager;
  final PlutoColumn? column;
  final Widget? child;

  const _BuildSortableWidget({
    Key? key,
    this.stateManager,
    this.column,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return column!.enableSorting
        ? InkWell(
            onTap: () {
              stateManager!.toggleSortColumn(column!);
            },
            child: child,
          )
        : child!;
  }
}

class _BuildColumnWidget extends StatelessWidget {
  final PlutoGridStateManager stateManager;
  final PlutoColumn column;
  final double height;

  const _BuildColumnWidget({
    required this.stateManager,
    required this.column,
    required this.height,
    Key? key,
  }) : super(key: key);

  double get padding =>
      column.titlePadding ??
      stateManager.configuration!.defaultColumnTitlePadding;

  bool get showSizedBoxForIcon =>
      column.isShowRightIcon && column.titleTextAlign.isRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: column.width,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: padding),
      decoration: stateManager.configuration!.enableColumnBorder
          ? BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: stateManager.configuration!.borderColor,
                  width: 1.0,
                ),
              ),
            )
          : const BoxDecoration(),
      child: DragTarget<PlutoColumn>(
        onWillAccept: (PlutoColumn? columnToDrag) {
          return columnToDrag != null && columnToDrag.key != column.key;
        },
        onMove: (DragTargetDetails<PlutoColumn> details) async {
          final columnToMove = details.data;

          if (columnToMove.key != column.key) {
            stateManager.eventManager!.addEvent(PlutoGridDragColumnEvent(
              column: columnToMove,
              targetColumn: column,
            ));
          }
        },
        builder: (dragContext, candidate, rejected) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                if (column.enableRowChecked)
                  _CheckboxAllSelectionWidget(
                    column: column,
                    stateManager: stateManager,
                  ),
                Expanded(
                  child: _ColumnTextWidget(
                    column: column,
                    stateManager: stateManager,
                    height: height,
                  ),
                ),
                if (showSizedBoxForIcon)
                  SizedBox(width: stateManager.configuration!.iconSize),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CheckboxAllSelectionWidget extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  final PlutoColumn? column;

  const _CheckboxAllSelectionWidget({
    required this.stateManager,
    this.column,
    Key? key,
  }) : super(key: key);

  @override
  __CheckboxAllSelectionWidgetState createState() =>
      __CheckboxAllSelectionWidgetState();
}

abstract class __CheckboxAllSelectionWidgetStateWithChange
    extends PlutoStateWithChange<_CheckboxAllSelectionWidget> {
  bool? _checked;

  bool get _hasCheckedRow => widget.stateManager.hasCheckedRow;

  bool get _hasUnCheckedRow => widget.stateManager.hasUnCheckedRow;

  @override
  void onChange() {
    resetState((update) {
      _checked = update<bool?>(
        _checked,
        _hasCheckedRow && _hasUnCheckedRow ? null : _hasCheckedRow,
      );
    });
  }
}

class __CheckboxAllSelectionWidgetState
    extends __CheckboxAllSelectionWidgetStateWithChange {
  void _handleOnChanged(bool? changed) {
    if (changed == _checked) {
      return;
    }

    changed ??= false;

    if (_checked == null) {
      changed = true;
    }

    widget.stateManager.toggleAllRowChecked(changed);

    if (widget.stateManager.onRowChecked != null) {
      widget.stateManager.onRowChecked!(
        PlutoGridOnRowCheckedAllEvent(isChecked: changed),
      );
    }

    setState(() {
      _checked = changed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlutoScaledCheckbox(
      value: _checked,
      handleOnChanged: _handleOnChanged,
      tristate: true,
      scale: 0.86,
      unselectedColor: widget.stateManager.configuration!.iconColor,
      activeColor: widget.stateManager.configuration!.activatedBorderColor,
      checkColor: widget.stateManager.configuration!.activatedColor,
    );
  }
}

class _ColumnTextWidget extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  final PlutoColumn column;

  final double height;

  const _ColumnTextWidget({
    required this.stateManager,
    required this.column,
    required this.height,
    Key? key,
  }) : super(key: key);

  @override
  __ColumnTextWidgetState createState() => __ColumnTextWidgetState();
}

abstract class __ColumnTextWidgetStateWithChange
    extends PlutoStateWithChange<_ColumnTextWidget> {
  bool? _isFilteredList;

  @override
  void onChange() {
    resetState((update) {
      _isFilteredList = update<bool?>(
        _isFilteredList,
        widget.stateManager.isFilteredColumn(widget.column),
      );
    });
  }

  void _handleOnPressedFilter() {
    widget.stateManager.showFilterPopup(
      context,
      calledColumn: widget.column,
    );
  }
}

class __ColumnTextWidgetState extends __ColumnTextWidgetStateWithChange {
  String? get _title =>
      widget.column.titleSpan == null ? widget.column.title : null;

  List<InlineSpan>? get _children => [
        if (widget.column.titleSpan != null) widget.column.titleSpan!,
        if (_isFilteredList!)
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: IconButton(
              icon: Icon(
                Icons.filter_alt_outlined,
                color: widget.stateManager.configuration!.iconColor,
                size: widget.stateManager.configuration!.iconSize,
              ),
              onPressed: _handleOnPressedFilter,
              constraints: BoxConstraints(
                maxHeight:
                    widget.height + (PlutoGridSettings.rowBorderWidth * 2),
              ),
            ),
          ),
      ];

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: _title,
        children: _children,
      ),
      style: widget.stateManager.configuration!.columnTextStyle,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      maxLines: 1,
      textAlign: widget.column.titleTextAlign.value,
    );
  }
}
