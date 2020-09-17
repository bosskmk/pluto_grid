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
