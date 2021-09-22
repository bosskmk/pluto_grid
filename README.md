## PlutoGrid for flutter - v2.5.0

[![codecov](https://codecov.io/gh/bosskmk/pluto_grid/branch/master/graph/badge.svg)](https://codecov.io/gh/bosskmk/pluto_grid)

<br>

PlutoGrid is a dataGrid that can be controlled by the keyboard on desktop and web.  
Of course, it works well on Android and IOS.

<br>

### [Demo Web](https://bosskmk.github.io/pluto_grid/build/web/index.html)
> You can try out various functions and usage methods right away.  
> All features provide example code.

<br>

### [Pub.Dev](https://pub.dev/packages/pluto_grid)
> Check out how to install from the official distribution site.

<br>

### [Documentation](https://github.com/bosskmk/pluto_grid/wiki)
> The documentation has more details.

<br>

### [ChangeLog](https://github.com/bosskmk/pluto_grid/blob/master/CHANGELOG.md)
> Please note the changes when changing the version of PlutoGrid you are using.

<br>

### [Issue](https://github.com/bosskmk/pluto_grid/issues)
> Report any questions or errors.
  
<br>
  
### Screenshots

#### Frozen columns on the left and right.
![PlutoGrid Nomal](https://bosskmk.github.io/images/pluto_grid/1.0.0/pluto_image_1.0.0_1.jpg)

<br>

#### Popup for select list type columns.
![PlutoGrid Select Popup](https://bosskmk.github.io/images/pluto_grid/1.0.0/pluto_image_1.0.0_2.jpg)

<br>

#### Popup for select date type columns.
![PlutoGrid Select Date](https://bosskmk.github.io/images/pluto_grid/1.0.0/pluto_image_1.0.0_3.jpg)

<br>

#### Cell renderer.
![PlutoGrid Cell renderer](https://bosskmk.github.io/images/pluto_grid/1.0.0/pluto_image_1.0.0_4.jpg)

<br>

#### Multi select. (Cells or Rows)
![PlutoGrid Multi select](https://bosskmk.github.io/images/pluto_grid/1.0.0/pluto_image_1.0.0_5.jpg)

<br>

#### Dual grid. (Moving between grids.)
![PlutoGrid Dual grid](https://bosskmk.github.io/images/pluto_grid/1.0.0/pluto_image_1.0.0_6.jpg)

<br>

#### A Dark mode.
![PlutoGrid Dual grid](https://bosskmk.github.io/images/pluto_grid/1.0.0/pluto_image_1.0.0_7.jpg)

<br>

### Example
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
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          onLoaded: (PlutoGridOnLoadedEvent event) {
            print(event);
          }
        ),
      ),
    );
  }
```

<br>

### Pluto series
> develop packages that make it easy to develop admin pages or CMS with Flutter.
* [PlutoGrid](https://github.com/bosskmk/pluto_grid)
* [PlutoMenuBar](https://github.com/bosskmk/pluto_menu_bar)

<br>

### Support

[![Buy me a coffee](https://www.buymeacoffee.com/assets/img/custom_images/white_img.png)](https://www.buymeacoffee.com/manki)

<br>

### License
> MIT
