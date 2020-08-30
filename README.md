## PlutoGrid for flutter - v0.1.5

PlutoGrid is a dataGrid for flutter. It is developed with Windows, Web first. There are plans to support Android and iOS as well.

> It is still in the development stage. Not recommended for use in production.

### Features  
- Column fixation : Columns can be fixed to the left or right of the grid.
- Column shift : Change the order of the columns by dragging the column title.
- Column sort : Sort the list by clicking on the column heading.
- Column width : Change the column width by dragging the icon to the right of the column title.
- Column action : Click the icon to the right of the column title, you can control the column with the column action menu.
- Column type : Text, Number, Select, Date.
- Multi selection : By long tapping or clicking and moving. (or Shift + ArrowKey)
- Copy & paste : Ctrl(macos : Meta) + C or V.
- Select Row Popup : Same as the grid, a selection popup that can be used when selecting an item from a list.
- Keyboard support : Arrow keys, Enter(Shift + Enter), Tab(Shift +Tab), Esc...

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
  PlutoColumn(
    title: 'leftFixedColumn',
    field: 'leftFixedColumn',
    type: PlutoColumnType.text(),
    fixed: PlutoColumnFixed.Left,
  ),
  PlutoColumn(
    title: 'readOnlyColumn',
    field: 'readOnlyColumn',
    type: PlutoColumnType.text(readOnly: true),
  ),
  PlutoColumn(
    title: 'textColumn',
    field: 'textColumn',
    type: PlutoColumnType.text(),
  ),
  PlutoColumn(
    title: 'selectColumn',
    field: 'selectColumn',
    type: PlutoColumnType.select(['One', 'Two', 'Three']),
  ),
  PlutoColumn(
    title: 'dateColumn',
    field: 'dateColumn',
    type: PlutoColumnType.datetime(),
  ),
  PlutoColumn(
    title: 'rightFixedColumn',
    field: 'rightFixedColumn',
    type: PlutoColumnType.number(),
    fixed: PlutoColumnFixed.Right,
  ),
];

List<PlutoRow> rows = [
  PlutoRow(
    cells: {
      'leftFixedColumn': PlutoCell(value: 'fixed column'),
      'readOnlyColumn': PlutoCell(value: 'read only column'),
      'textColumn': PlutoCell(value: 'text column'),
      'selectColumn': PlutoCell(value: 'One'),
      'dateColumn': PlutoCell(value: '2020-01-01'),
      'rightFixedColumn': PlutoCell(value: 10000),
    }, 
  ),
  PlutoRow(
    cells: {
      'leftFixedColumn': PlutoCell(value: 'fixed column'),
      'readOnlyColumn': PlutoCell(value: 'read only column'),
      'textColumn': PlutoCell(value: 'text column'),
      'selectColumn': PlutoCell(value: 'Two'),
      'dateColumn': PlutoCell(value: '2020-01-02'),
      'rightFixedColumn': PlutoCell(value: 10001),
    },
  ),
  PlutoRow(
    cells: {
      'leftFixedColumn': PlutoCell(value: 'fixed column'),
      'readOnlyColumn': PlutoCell(value: 'read only column'),
      'textColumn': PlutoCell(value: 'text column'),
      'selectColumn': PlutoCell(value: 'Three'),
      'dateColumn': PlutoCell(value: '2020-01-03'),
      'rightFixedColumn': PlutoCell(value: 10002),
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