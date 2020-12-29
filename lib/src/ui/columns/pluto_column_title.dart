import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoColumnTitle extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;
  final PlutoColumn column;

  PlutoColumnTitle({
    @required this.stateManager,
    @required this.column,
  }) : super(key: column.key);

  @override
  _PlutoColumnTitleState createState() => _PlutoColumnTitleState();
}

abstract class _PlutoColumnTitleStateWithChange
    extends PlutoStateWithChange<PlutoColumnTitle> {
  PlutoColumnSort sort;

  @override
  void onChange() {
    resetState((update) {
      sort = update<PlutoColumnSort>(sort, widget.column.sort);
    });
  }
}

class _PlutoColumnTitleState extends _PlutoColumnTitleStateWithChange {
  Offset _currentPosition;

  void _showContextMenu(BuildContext context, Offset position) async {
    final PlutoGridColumnMenuItem selectedMenu = await showColumnMenu(
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
      case PlutoGridColumnMenuItem.setFilter:
        widget.stateManager.showFilterPopup(
          context,
          calledColumn: widget.column,
        );
        break;
      case PlutoGridColumnMenuItem.resetFilter:
        widget.stateManager.setFilter(null);
        break;
    }
  }

  void _handleOnTapUpContextMenu(TapUpDetails details) {
    _showContextMenu(context, details.globalPosition);
  }

  void _handleOnHorizontalDragUpdateContextMenu(DragUpdateDetails details) {
    _currentPosition = details.localPosition;
  }

  void _handleOnHorizontalDragEndContextMenu(DragEndDetails details) {
    widget.stateManager
        .resizeColumn(widget.column.key, _currentPosition.dx - 20);
  }

  @override
  Widget build(BuildContext context) {
    final _columnWidget = _BuildSortableWidget(
      stateManager: widget.stateManager,
      column: widget.column,
      child: _BuildColumnWidget(
        stateManager: widget.stateManager,
        column: widget.column,
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
        if (widget.column.enableContextMenu)
          Positioned(
            right: -3,
            child: GestureDetector(
              onTapUp: _handleOnTapUpContextMenu,
              onHorizontalDragUpdate: _handleOnHorizontalDragUpdateContextMenu,
              onHorizontalDragEnd: _handleOnHorizontalDragEndContextMenu,
              child: Container(
                height: widget.stateManager.columnHeight,
                alignment: Alignment.center,
                child: IconButton(
                  icon: PlutoGridColumnIcon(
                    sort: widget.column.sort,
                    color: widget.stateManager.configuration.iconColor,
                  ),
                  iconSize: widget.stateManager.configuration.iconSize,
                  onPressed: null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class PlutoGridColumnIcon extends StatelessWidget {
  final PlutoColumnSort sort;
  final Color color;

  PlutoGridColumnIcon({
    this.sort,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    switch (sort) {
      case PlutoColumnSort.ascending:
        return Transform.rotate(
          angle: 90 * pi / 90,
          child: const Icon(
            Icons.sort,
            color: Colors.green,
          ),
        );
      case PlutoColumnSort.descending:
        return const Icon(
          Icons.sort,
          color: Colors.red,
        );
      default:
        return Icon(
          Icons.dehaze,
          color: color ?? Colors.black26,
        );
    }
  }
}

class _BuildDraggableWidget extends StatelessWidget {
  final PlutoGridStateManager stateManager;
  final PlutoColumn column;
  final Widget child;

  const _BuildDraggableWidget({
    Key key,
    this.stateManager,
    this.column,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable(
      onDragEnd: (dragDetails) {
        stateManager.moveColumn(
            column.key, dragDetails.offset.dx + (column.width / 2));
      },
      feedback: PlutoShadowContainer(
        width: column.width,
        height: PlutoGridSettings.rowHeight,
        backgroundColor: stateManager.configuration.gridBackgroundColor,
        borderColor: stateManager.configuration.gridBorderColor,
        child: Text(
          column.title,
          style: stateManager.configuration.columnTextStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          softWrap: false,
        ),
      ),
      child: child,
    );
  }
}

class _BuildSortableWidget extends StatelessWidget {
  final PlutoGridStateManager stateManager;
  final PlutoColumn column;
  final Widget child;

  const _BuildSortableWidget({
    Key key,
    this.stateManager,
    this.column,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return column.enableSorting
        ? InkWell(
            onTap: () {
              stateManager.toggleSortColumn(column.key);
            },
            child: child,
          )
        : child;
  }
}

class _BuildColumnWidget extends StatelessWidget {
  final PlutoGridStateManager stateManager;
  final PlutoColumn column;

  const _BuildColumnWidget({
    Key key,
    this.stateManager,
    this.column,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: column.width,
      height: PlutoGridSettings.rowHeight,
      padding:
          const EdgeInsets.symmetric(horizontal: PlutoGridSettings.cellPadding),
      decoration: stateManager.configuration.enableColumnBorder
          ? BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: stateManager.configuration.borderColor,
                  width: 1.0,
                ),
              ),
            )
          : const BoxDecoration(),
      child: Align(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckboxAllSelectionWidget extends PlutoStatefulWidget {
  final PlutoColumn column;
  final PlutoGridStateManager stateManager;

  _CheckboxAllSelectionWidget({
    this.column,
    this.stateManager,
  });

  @override
  __CheckboxAllSelectionWidgetState createState() =>
      __CheckboxAllSelectionWidgetState();
}

abstract class __CheckboxAllSelectionWidgetStateWithChange
    extends PlutoStateWithChange<_CheckboxAllSelectionWidget> {
  bool checked;

  bool get hasCheckedRow => widget.stateManager.hasCheckedRow;

  bool get hasUnCheckedRow => widget.stateManager.hasUnCheckedRow;

  @override
  void onChange() {
    resetState((update) {
      checked = update<bool>(
        checked,
        hasCheckedRow && hasUnCheckedRow ? null : hasCheckedRow,
      );
    });
  }
}

class __CheckboxAllSelectionWidgetState
    extends __CheckboxAllSelectionWidgetStateWithChange {
  void _handleOnChanged(bool changed) {
    if (changed == checked) {
      return;
    }

    changed ??= false;

    if (checked == null) {
      changed = true;
    }

    widget.stateManager.toggleAllRowChecked(changed);

    setState(() {
      checked = changed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlutoScaledCheckbox(
      value: checked,
      handleOnChanged: _handleOnChanged,
      tristate: true,
      scale: 0.86,
      unselectedColor: widget.stateManager.configuration.iconColor,
      activeColor: widget.stateManager.configuration.activatedBorderColor,
      checkColor: widget.stateManager.configuration.activatedColor,
    );
  }
}

class _ColumnTextWidget extends PlutoStatefulWidget {
  final PlutoColumn column;
  final PlutoGridStateManager stateManager;

  _ColumnTextWidget({
    this.column,
    this.stateManager,
  });

  @override
  __ColumnTextWidgetState createState() => __ColumnTextWidgetState();
}

abstract class __ColumnTextWidgetStateWithChange
    extends PlutoStateWithChange<_ColumnTextWidget> {
  bool isFilteredList;

  @override
  void onChange() {
    resetState((update) {
      isFilteredList = update<bool>(
        isFilteredList,
        widget.stateManager.isFilteredColumn(widget.column),
      );
    });
  }

  void handleOnPressedFilter() {
    widget.stateManager.showFilterPopup(
      context,
      calledColumn: widget.column,
    );
  }
}

class __ColumnTextWidgetState extends __ColumnTextWidgetStateWithChange {
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: widget.column.title,
        children: [
          if (isFilteredList)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: IconButton(
                icon: Icon(
                  Icons.filter_alt_outlined,
                  color: widget.stateManager.configuration.iconColor,
                  size: widget.stateManager.configuration.iconSize,
                ),
                onPressed: handleOnPressedFilter,
              ),
            ),
        ],
      ),
      style: widget.stateManager.configuration.columnTextStyle,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      maxLines: 1,
    );
  }
}
