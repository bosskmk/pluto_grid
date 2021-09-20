import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

typedef PlutoColumnValueFormatter = String Function(dynamic value);

typedef PlutoColumnRenderer = Widget Function(
    PlutoColumnRendererContext rendererContext);

class PlutoColumn {
  /// A title to be displayed on the screen.
  String title;

  /// Specifies the field name of the row to be connected to the column.
  String field;

  /// Set the column type.
  PlutoColumnType? type;

  /// Set the width of the column.
  double width;

  double minWidth;

  /// Text alignment in Cell. (Left, Right)
  PlutoColumnTextAlign textAlign;

  /// Freeze the column to the left and right.
  PlutoColumnFrozen frozen;

  /// Set column sorting.
  PlutoColumnSort sort;

  /// Formatter for display of cell values.
  PlutoColumnValueFormatter? formatter;

  /// Apply the formatter in the editing state.
  /// However, it is applied only when the cell is readonly
  /// or the text cannot be directly modified, such as in the form of select popup.
  bool applyFormatterInEditing;

  /// Rendering for cell widget.
  PlutoColumnRenderer? renderer;

  /// Change the position of the column by dragging the column title.
  bool enableColumnDrag;

  /// Change the position of the row by dragging the icon in the cell.
  bool enableRowDrag;

  /// A checkbox appears in the cell of the column.
  bool enableRowChecked;

  /// Sort rows by tapping on the column heading.
  bool enableSorting;

  /// Displays the right icon of the column title.
  bool enableContextMenu;

  /// Diaplay the right icon for drop to resize the column
  /// Valid only when [enableContextMenu] is noactivated.
  bool enableDropToResize;

  /// Displays filter-related menus in the column context menu.
  /// Valid only when [enableContextMenu] is activated.
  bool enableFilterMenuItem;

  /// Displays Hide column menu in the column context menu.
  /// Valid only when [enableContextMenu] is activated.
  bool enableHideColumnMenuItem;

  /// Displays Set columns menu in the column context menu.
  /// Valid only when [enableContextMenu] is activated.
  bool enableSetColumnsMenuItem;

  /// Entering the Enter key or tapping the cell enters the Editing mode.
  bool? enableEditingMode;

  /// Hide the column.
  bool hide;

  PlutoColumn({
    required this.title,
    required this.field,
    required this.type,
    this.width = PlutoGridSettings.defaultColumnWidth,
    this.minWidth = PlutoGridSettings.defaultMinColumnWidth,
    this.textAlign = PlutoColumnTextAlign.left,
    this.frozen = PlutoColumnFrozen.none,
    this.sort = PlutoColumnSort.none,
    this.formatter,
    this.applyFormatterInEditing = false,
    this.renderer,
    this.enableColumnDrag = true,
    this.enableRowDrag = false,
    this.enableRowChecked = false,
    this.enableSorting = true,
    this.enableContextMenu = true,
    this.enableDropToResize = false,
    this.enableFilterMenuItem = true,
    this.enableHideColumnMenuItem = true,
    this.enableSetColumnsMenuItem = true,
    this.enableEditingMode = true,
    this.hide = false,
  }) : _key = UniqueKey();

  /// Column key
  final Key _key;

  Key get key => _key;

  bool get hasRenderer => renderer != null;

  FocusNode? _filterFocusNode;

  FocusNode? get filterFocusNode {
    return _filterFocusNode;
  }

  PlutoFilterType? _defaultFilter;

  PlutoFilterType get defaultFilter =>
      _defaultFilter ?? const PlutoFilterTypeContains();

  void setFilterFocusNode(FocusNode? node) {
    _filterFocusNode = node;
  }

  void setDefaultFilter(PlutoFilterType filter) {
    _defaultFilter = filter;
  }

  String formattedValueForType(dynamic value) {
    if (type.isNumber) {
      return type.number!.applyFormat(value);
    }

    return value.toString();
  }

  String formattedValueForDisplay(dynamic value) {
    if (formatter != null) {
      return formatter!(value).toString();
    }

    return formattedValueForType(value);
  }

  String formattedValueForDisplayInEditing(dynamic value) {
    if (formatter != null) {
      final bool allowFormatting =
          type!.readOnly! || type.isSelect || type.isTime || type.isDate;

      if (applyFormatterInEditing && allowFormatting) {
        return formatter!(value).toString();
      }
    }

    return value.toString();
  }
}

class PlutoColumnRendererContext {
  final PlutoColumn? column;

  final int? rowIdx;

  final PlutoRow? row;

  final PlutoCell? cell;

  final PlutoGridStateManager? stateManager;

  PlutoColumnRendererContext({
    this.column,
    this.rowIdx,
    this.row,
    this.cell,
    this.stateManager,
  });
}

enum PlutoColumnTextAlign {
  left,
  right,
}

extension PlutoColumnTextAlignExtension on PlutoColumnTextAlign {
  TextAlign get value {
    return this == PlutoColumnTextAlign.right
        ? TextAlign.right
        : TextAlign.left;
  }

  bool get isLeft => this == PlutoColumnTextAlign.left;

  bool get isRight => this == PlutoColumnTextAlign.right;
}

enum PlutoColumnFrozen {
  none,
  left,
  right,
}

extension PlutoColumnFrozenExtension on PlutoColumnFrozen {
  bool get isNone {
    return this == PlutoColumnFrozen.none;
  }

  bool get isLeft {
    return this == PlutoColumnFrozen.left;
  }

  bool get isRight {
    return this == PlutoColumnFrozen.right;
  }

  bool get isFrozen {
    return this == PlutoColumnFrozen.left || this == PlutoColumnFrozen.right;
  }
}

enum PlutoColumnSort {
  none,
  ascending,
  descending,
}

extension PlutoColumnSortExtension on PlutoColumnSort {
  bool get isNone {
    return this == PlutoColumnSort.none;
  }

  bool get isAscending {
    return this == PlutoColumnSort.ascending;
  }

  bool get isDescending {
    return this == PlutoColumnSort.descending;
  }

  String toShortString() {
    return toString().split('.').last;
  }

  PlutoColumnSort fromString(String value) {
    if (value == PlutoColumnSort.ascending.toShortString()) {
      return PlutoColumnSort.ascending;
    } else if (value == PlutoColumnSort.descending.toShortString()) {
      return PlutoColumnSort.descending;
    } else {
      return PlutoColumnSort.none;
    }
  }
}
