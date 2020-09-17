## PlutoGrid for flutter - v0.1.9

PlutoGrid is a dataGrid for flutter. It is developed with Windows, Web first. There are plans to support Android and iOS as well.

> It is still in the development stage. Not recommended for use in production.

### Features  
- Column fixation : Columns can be fixed to the left or right of the grid.
- Column shift : Change the order of the columns by dragging the column title.
- Column sort : Sort the list by clicking on the column heading.
- Column width : Change the column width by dragging the icon to the right of the column title.
- Column action : Click the icon to the right of the column title, you can control the column with the column action menu.
- Column type : Text, Number, Select, Date, Time.
- Multi selection : By long tapping or clicking and moving. (or Shift + ArrowKey)
- Copy & paste : Ctrl(macos : Meta) + C or V.
- Select Row Popup : Same as the grid, a selection popup that can be used when selecting an item from a list.
- Keyboard support : Arrow keys, Enter(Shift + Enter), Tab(Shift +Tab), Esc...
- A dual mode : Run two grids left and right simultaneously.

### Demo
[Demo Web](https://bosskmk.github.io/pluto_grid/build/web/index.html)

### Installation
[pub.dev](https://pub.dev/packages/pluto_grid)

### Screenshots

![PlutoGrid Image](https://bosskmk.github.io/images/pluto_image1.jpg)

![PlutoGrid Image](https://bosskmk.github.io/images/pluto_image2.jpg)

![PlutoGrid Image](https://bosskmk.github.io/images/pluto_image3.jpg)

### Usage
Generate the data to be used in the grid.
```dart

List<PlutoColumn> columns = [
  /// Text Column definition
  PlutoColumn(
    title: 'text column',
    field: 'text_field',
    type: PlutoColumnType.text(),
  ),
  /// Number Column definition
  PlutoColumn(
    title: 'number column',
    field: 'number_field',
    type: PlutoColumnType.number(),
  ),
  /// Select Column definition
  PlutoColumn(
    title: 'select column',
    field: 'select_field',
    type: PlutoColumnType.select(['item1', 'item2', 'item3']),
  ),
  /// Datetime Column definition
  PlutoColumn(
    title: 'date column',
    field: 'date_field',
    type: PlutoColumnType.date(),
  ),
  /// Time Column definition
  PlutoColumn(
    title: 'time column',
    field: 'time_field',
    type: PlutoColumnType.time(),
  ),
];

List<PlutoRow> rows = [
  PlutoRow(
    cells: {
      'text_field': PlutoCell(value: 'Text cell value1'),
      'number_field': PlutoCell(value: 2020),
      'select_field': PlutoCell(value: 'item1'),
      'date_field': PlutoCell(value: '2020-08-06'),
      'time_field': PlutoCell(value: '12:30'),
    },
  ),
  PlutoRow(
    cells: {
      'text_field': PlutoCell(value: 'Text cell value2'),
      'number_field': PlutoCell(value: 2021),
      'select_field': PlutoCell(value: 'item2'),
      'date_field': PlutoCell(value: '2020-08-07'),
      'time_field': PlutoCell(value: '18:45'),
    },
  ),
  PlutoRow(
    cells: {
      'text_field': PlutoCell(value: 'Text cell value3'),
      'number_field': PlutoCell(value: 2022),
      'select_field': PlutoCell(value: 'item3'),
      'date_field': PlutoCell(value: '2020-08-08'),
      'time_field': PlutoCell(value: '23:59'),
    },
  ),
];
```

Create a grid with the data created above.
```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlutoGrid Demo'),
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          onChanged: (PlutoOnChangedEvent event) {
            print(event);
          },
          onLoaded: (PlutoOnLoadedEvent event) {
            print(event);
          }
        ),
      ),
    );
  }
```

### Coming soon

* Column types (DateTime)
* Column filtering
* Row selection
* Multi column sorting
* Paging
* Control UI for mobile