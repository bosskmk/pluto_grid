## [2.4.1] - 2021. 8. 1

* Fix pagination bug.

## [2.4.0] - 2021. 7. 31

* Added pagination. 
* Added debounce on keyboard input in filter.

## [2.3.0] - 2021. 7. 7

* Added onDoubleTap, onSecondaryTap cell events.
* Hide secondary scrollbar.

## [2.2.1] - 2021. 6. 26

* Added enableDropToResize option when creating a column. (enables an icon for adjusting the width of a column when there is no context menu)
* Fix scroll bar drag behavior

## [2.2.0] - 2021. 5. 29

* Add callback to row checks developed by https://github.com/MrCasCode.

## [2.1.0] - 2021. 5. 19

* flutter 2.2.x compatible

## [2.0.0] - 2021. 5. 14

* Change scroll physics.
* Fix a bug when dragging rows. 
* Stable release.

## [2.0.0-nullsafety.2] - 2021. 5. 1

* Fix errors of tests on null-safety.
* Fix focus problems on web.

## [2.0.0-nullsafety.1] - 2021. 4. 15

* Edit dependency.

## [2.0.0-nullsafety.0] - 2021. 4. 9

* Null safety version.
* Fix CupertinoScrollBar error.(In flutter 2.1.0.xxx)

## [1.2.0] - 2021. 3. 13

* Add moveRowsByIndex.
* Fix focusing bug.
* Apply strong-mode.
* Allow custom key in row.

* Rename moveRows to moveRowsByOffset.
* Add moveRowsByIndex.
* Fix focus.

## [1.1.1] - 2021. 1. 22

* Changed the return value of FocusNode's onKey callback function from bool to KeyEventResult.
* Add china locale.

## [1.1.0] - 2021. 1. 16

* Add hide columns.

## [1.0.0] - 2020. 12. 30

* Class name change. Just like changing PlutoConfiguration to PlutoGridConfiguration, the word Grid was added in the middle.
  - PlutoStateManager > PlutoGridStateManager
  - PlutoOnLoadedEvent > PlutoGridOnLoadedEvent
  - Many other classes...

## [1.0.0-pre.10] - 2020. 12. 21

* Fix sorting error when null value.

## [1.0.0-pre.9] - 2020. 12. 20

* The method of setting the filter has changed. columnFilters in configuration changed to columnFilterConfig.
* Different default filters can be set for each column.
* Modified to close the popup if there is no filter to clear when clicking the clear button in the filter popup.
* Rename DatetimeHelper to DateTimeHelper.

## [1.0.0-pre.8] - 2020. 12. 16

* Add filtering.
* Rename PlutoSelectingMode.square to PlutoSelectingMode.cell.
* Remove originalValue property from PlutoCell.

## [1.0.0-pre.7] - 2020. 11. 24

* Added to PlutoConfiguration to allow you to set the row height.

## [1.0.0-pre.6] - 2020. 11. 23

* Add Czech locale.
* Rename the Fix column to freeze column.

## [1.0.0-pre.5] - 2020. 11. 18

* Add enableEditingMode to PlutoColumn.

## [1.0.0-pre.4] - 2020. 11. 16

* Enable constant_identifier_names.
  - ex) `PlutoColumnFixed.Left` > `PlutoColumnFixed.left`
  - ex) `PlutoSelectingMode.Row` > `PlutoSelectingMode.row`
  - All existing constants such as enum are changed.
* Add a loading indicator.

## [1.0.0-pre.3] - 2020. 11. 13

* Fix bug, scrolling and row movement errors with createHeader present.
* Modified to move based on half the size of the cell or row.
* Update scrollbar status when moving with a keyboard.
* To disable dragging of rows while columns are be sorted.
* Add visualizations for dragging rows.
* Modified so that onPointerMove event occurs only in drag state.
* Applying scrolling up or down the grid when dragging a row.

## [1.0.0-pre.2] - 2020. 11. 09

* Add insertRows to PlutoStateManager.
* Remove setCurrentRowIdx, clearCurrentRowIdx, updateCurrentRowIdx from PlutoStateManager.
* Change the parameter of setCurrentSelectingPosition in PlutoStateManager.
* Add draggable scrollbar.

## [1.0.0-pre.1] - 2020. 11. 05

##### Breaking changes:

* PlutoGrid.popup has been deleted.  
  PlutoGrid.popup() has been removed.  
  Just clear the popup and create it with PlutoGrid().
* The column property enableDraggable has been changed to enableColumnDrag.

##### Improvements: 

* Column properties have been added.
  - enableRowDrag : If set to true, an icon is create in the cell of the column, and the row can be moved by dragging it.
  - enableRowChecked : If set to true, a check box is create in the cell of the column.
  - renderer : You can change the displayed cell.
  - applyFormatterInEditing : If this is set to true, the value changed by a formatter is a reflected in the editing state. However, it is only in the readonly state, or the state in which the cell value cannot be directly modified in the form of popup.

## [0.1.21] - 2020. 11. 01

* Add display property for the dual grid.
* Add shortcuts. (home, end, pageUp, pageDown)

## [0.1.20] - 2020. 10. 28

* Add textAlign to column property.(PlutoColumnTextAlign.Left, or Right) [#49](https://github.com/bosskmk/pluto_grid/issues/49)

## [0.1.19] - 2020. 10. 23

* Add enableMoveDownAfterSelecting, enterKeyAction in PlutoConfiguration.
* Add currentSelectingPositionList in PlutoStateManager.

## [0.1.18] - 2020. 10. 16

* Add valueFormatter for display of the cell value.

## [0.1.17] - 2020. 10. 4

* Cell selection problem. [#35](https://github.com/bosskmk/pluto_grid/issues/35)
* Modified so that AutoSize of column operates according to default TextStyle.

## [0.1.16] - 2020. 10. 2

* Fixed column problem when adjusting column width.
* When the date is MM/dd/yyyy, the initial value of the pop-up is incorrect.
* When startDate, endDate are present, the initial value of the popup is not filled or scrolling fails.
* When the date is MM/dd/yyyy, misalignment error.
* Modify to operate the sorting criteria in the order of items in the Select Type Column.

## [0.1.15] - 2020. 09. 28

* Modified so that the Grid does not force focus and works properly according to the situation in which focus get received or taken away.

## [0.1.14] - 2020. 09. 27

* Fixed cell movement error.

## [0.1.13] - 2020. 09. 26

* Change the column icon.
* Fix a bug that the previous data wasn't created when moving up in the date selection popup.
* enable/disable border of the between columns.
* Add a configuration. (Dark mode or custom setting)
* Fix a bug that the newly added fixed column doesn't scroll correctly.
* Ignore to move cell when pressing shift + arrow left or right, in edit mode.

## [0.1.12] - 2020. 9. 23

* Select all - Control(Meta on MacOs) + A.

## [0.1.11] - 2020. 9. 21

* Add Selecting mode for row.
* Removing rows by selecting cells.

## [0.1.10] - 2020. 9. 17

* Add removing row.
* Add example for adding and removing row.

## [0.1.9] - 2020. 9. 17

* Add None Selecting mode for states that do not require multi-selection.
* Add selecting-mode for selecting date range.
* Difference in Enter key in TextField when using RawKeyboardListener overlapping.  [https://github.com/flutter/flutter/issues/65170](https://github.com/flutter/flutter/issues/65170)

## [0.1.8] - 2020. 9. 3

* BugFix : RawKeyEvent's logicalKey.keyLabel return value changed from null to "".

## [0.1.7] - 2020. 9. 3

* Change the way to move between grids in dual grid mode. When moving the arrow keys, the focus moves when reaching the left and right ends.
* Update Demo.

## [0.1.6] - 2020. 9. 2

* Change datetime column type to date.
* Fix selecting cell bug.
* Add dual mode grid.
* Add time type column.
* Update Demo.

## [0.1.5] - 2020. 8. 31

* Change UI for datetime popup.

## [0.1.4] - 2020. 8. 29

* fixed column bug. [#1](https://github.com/bosskmk/pluto_grid/issues/1)

## [0.1.3] - 2020. 8. 28

* Multi-selection is canceled when clicking the current cell in the multi-selection state.
* Even when the cell is in the modified state, long tab to enter the multi-select mode.
* Added column type for date.(datetime will be soon)

## [0.1.2] - 2020. 8. 27

* Fix bug : Error not working properly according to fixed columns when selecting multiple cells.
* Multi selection with KeyBoard : Multi selection with Shift and arrow keys.

## [0.1.1] - 2020. 8. 26

* Column type : Add number type cell.

## [0.1.0] - 2020. 8. 26

* Column fixation : Columns can be fixed to the left or right of the grid.
* Column shift : Change the order of the columns by dragging the column title.
* Column sort : Sort the list by clicking on the column heading.
* Column width : Change the column width by dragging the icon to the right of the column title.
* Column action : Click the icon to the right of the column title, you can control the column with the column action menu.
* Multi selection : By long tapping or clicking and moving.
* Copy & paste : Ctrl(macos : Meta) + C or V.
* Select Row Popup : Same as the grid, a selection popup that can be used when selecting an item from a list.
* Keyboard support : Arrow keys, Enter(Shift + Enter), Tab(Shift +Tab), Esc...
