enum PlutoGridMode {
  /// {@template pluto_grid_mode_normal}
  /// Basic mode with most functions not limited, such as editing and selection.
  /// {@endtemplate}
  normal,

  /// {@template pluto_grid_mode_readOnly}
  /// Cell cannot be edited.
  /// To try to edit by force, it is possible as follows.
  ///
  /// ```dart
  /// stateManager.changeCellValue(
  ///   stateManager.currentCell!,
  ///   'test',
  ///   force: true,
  /// );
  /// ```
  /// {@endtemplate}
  readOnly,

  /// {@template pluto_grid_mode_select}
  /// Mode for selecting one list from a specific list.
  /// Tap a row or press Enter to select the current row.
  ///
  /// [select]
  /// Call the [PlutoGrid.onSelected] callback when the selected row is tapped.
  /// To select an unselected row, select the row and then tap once more.
  /// [selectWithOneTap]
  /// Same as [select], but calls [PlutoGrid.onSelected] with one tap.
  ///
  /// This mode is non-editable, but programmatically possible.
  /// ```dart
  /// stateManager.changeCellValue(
  ///   stateManager.currentRow!.cells['column_1']!,
  ///   value,
  ///   force: true,
  /// );
  /// ```
  /// {@endtemplate}
  select,

  /// {@macro pluto_grid_mode_select}
  selectWithOneTap,

  /// {@template pluto_grid_mode_multiSelect}
  /// Mode to select multiple rows.
  /// When a row is tapped, it is selected or deselected and the [PlutoGrid.onSelected] callback is called.
  /// [PlutoGridOnSelectedEvent.selectedRows] contains the selected rows.
  /// When a row is selected with keyboard shift + arrowDown/Up keys,
  /// the [PlutoGrid.onSelected] callback is called only when the Enter key is pressed.
  /// When the Escape key is pressed,
  /// the selected row is canceled and the [PlutoGrid.onSelected] callback is called
  /// with a [PlutoGridOnSelectedEvent.selectedRows] value of null.
  /// {@endtemplate}
  multiSelect,

  /// {@template pluto_grid_mode_popup}
  /// This is a mode for popup type.
  /// It is used when calling a popup for filtering or column setting
  /// inside [PlutoGrid], and it is not a mode for users.
  ///
  /// If the user wants to run [PlutoGrid] as a popup,
  /// use [PlutoGridPopup] or [PlutoGridDualGridPopup].
  /// {@endtemplate}
  popup;

  bool get isNormal => this == PlutoGridMode.normal;

  bool get isReadOnly => this == PlutoGridMode.readOnly;

  bool get isEditableMode => isNormal || isPopup;

  bool get isSelectMode => isSingleSelectMode || isMultiSelectMode;

  bool get isSingleSelectMode => isSelect || isSelectWithOneTap;

  bool get isMultiSelectMode => isMultiSelect;

  bool get isSelect => this == PlutoGridMode.select;

  bool get isSelectWithOneTap => this == PlutoGridMode.selectWithOneTap;

  bool get isMultiSelect => this == PlutoGridMode.multiSelect;

  bool get isPopup => this == PlutoGridMode.popup;
}

/// When calling loading screen with [PlutoGridStateManager.setShowLoading] method
/// Determines the level of loading.
///
/// {@template pluto_grid_loading_level_grid}
/// [grid] makes the entire grid opaque and puts the loading indicator in the center.
/// The user is in a state where no interaction is possible.
/// {@endtemplate}
///
/// {@template pluto_grid_loading_level_rows}
/// [rows] represents the [LinearProgressIndicator] at the top of the widget area
/// that displays the rows.
/// User can interact.
/// {@endtemplate}
///
/// {@template pluto_grid_loading_level_rowsBottomCircular}
/// [rowsBottomCircular] represents the [CircularProgressIndicator] at the bottom of the widget
/// that displays the rows.
/// User can interact.
/// {@endtemplate}
enum PlutoGridLoadingLevel {
  /// {@macro pluto_grid_loading_level_grid}
  grid,

  /// {@macro pluto_grid_loading_level_rows}
  rows,

  /// {@macro pluto_grid_loading_level_rowsBottomCircular}
  rowsBottomCircular;

  bool get isGrid => this == PlutoGridLoadingLevel.grid;

  bool get isRows => this == PlutoGridLoadingLevel.rows;

  bool get isRowsBottomCircular =>
      this == PlutoGridLoadingLevel.rowsBottomCircular;
}
