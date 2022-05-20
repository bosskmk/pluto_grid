import 'dart:convert';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid_export/pluto_grid_export.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class ExportScreen extends StatefulWidget {
  static const routeName = 'feature/export';

  const ExportScreen({Key? key}) : super(key: key);

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final List<PlutoColumn> columns = [];

  final List<PlutoRow> rows = [];

  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();

    columns.addAll([
      PlutoColumn(
        title: 'Column 1',
        field: 'column1',
        type: PlutoColumnType.text(),
        enableRowDrag: true,
        enableRowChecked: true,
        width: 250,
        minWidth: 175,
        renderer: (rendererContext) {
          return Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                ),
                onPressed: () {
                  rendererContext.stateManager.insertRows(
                    rendererContext.rowIdx,
                    [rendererContext.stateManager.getNewRow()],
                  );
                },
                iconSize: 18,
                color: Colors.green,
                padding: const EdgeInsets.all(0),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outlined,
                ),
                onPressed: () {
                  rendererContext.stateManager
                      .removeRows([rendererContext.row]);
                },
                iconSize: 18,
                color: Colors.red,
                padding: const EdgeInsets.all(0),
              ),
              Expanded(
                child: Text(
                  rendererContext.row.cells[rendererContext.column.field]!.value
                      .toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
      PlutoColumn(
        title: 'Column 2',
        field: 'column2',
        type: PlutoColumnType.select(<String>['red', 'blue', 'green']),
        renderer: (rendererContext) {
          Color textColor = Colors.black;

          if (rendererContext.cell.value == 'red') {
            textColor = Colors.red;
          } else if (rendererContext.cell.value == 'blue') {
            textColor = Colors.blue;
          } else if (rendererContext.cell.value == 'green') {
            textColor = Colors.green;
          }

          return Text(
            rendererContext.cell.value.toString(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Column 3',
        field: 'column3',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Column 4',
        field: 'column4',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Column 5',
        field: 'column5',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        renderer: (rendererContext) {
          return Image.asset('assets/images/cat.jpg');
        },
      ),
    ]);

    rows.addAll(DummyData.rowsByColumns(length: 15, columns: columns));
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Export / download as CSV',
      topTitle: 'Export / download as CSV',
      topContents: const [
        Text('You can export grid contents as CSV or TSV'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/demo/lib/screen/feature/export_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
        onLoaded: (PlutoGridOnLoadedEvent event) {
          event.stateManager.setSelectingMode(PlutoGridSelectingMode.cell);

          stateManager = event.stateManager;
        },
        createHeader: (stateManager) => _Header(stateManager: stateManager),
        // configuration: PlutoConfiguration.dark(),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({
    required this.stateManager,
    Key? key,
  }) : super(key: key);

  final PlutoGridStateManager stateManager;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  void _defaultExportGridAsCSV() async {
    String title = "pluto_grid_export";
    var exported = const Utf8Encoder()
        .convert(PlutoGridExport.exportCSV(widget.stateManager));
    await FileSaver.instance.saveFile("$title.csv", exported, ".csv");
  }

  void _defaultExportGridAsCSVCompatibleWithExcel() async {
    String title = "pluto_grid_export";
    var exportCSV = PlutoGridExport.exportCSV(widget.stateManager);
    var exported = const Utf8Encoder().convert(
        // FIX Add starting \u{FEFF} / 0xEF, 0xBB, 0xBF
        // This allows open the file in Excel with proper character interpretation
        // See https://stackoverflow.com/a/155176
        '\u{FEFF}$exportCSV');
    await FileSaver.instance.saveFile("$title.csv", exported, ".csv");
  }

  void _defaultExportGridAsCSVFakeExcel() async {
    String title = "pluto_grid_export";
    var exportCSV = PlutoGridExport.exportCSV(widget.stateManager);
    var exported = const Utf8Encoder().convert(
        // FIX Add starting \u{FEFF} / 0xEF, 0xBB, 0xBF
        // This allows open the file in Excel with proper character interpretation
        // See https://stackoverflow.com/a/155176
        '\u{FEFF}$exportCSV');
    await FileSaver.instance.saveFile("$title.xls", exported, ".xls");
  }

  void _exportGridAsTSV() async {
    String title = "pluto_grid_export";
    var exported = const Utf8Encoder().convert(PlutoGridExport.exportCSV(
      widget.stateManager,
      fieldDelimiter: "\t",
    ));
    await FileSaver.instance.saveFile("$title.csv", exported, ".csv");
  }

  void _defaultExportGridAsCSVWithSemicolon() async {
    String title = "pluto_grid_export";
    var exported = const Utf8Encoder().convert(PlutoGridExport.exportCSV(
      widget.stateManager,
      fieldDelimiter: ";",
    ));
    await FileSaver.instance.saveFile("$title.csv", exported, ".csv");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: _defaultExportGridAsCSV,
                  child: const Text("Export to CSV")),
              ElevatedButton(
                  onPressed: _defaultExportGridAsCSVWithSemicolon,
                  child: const Text("Export to CSV with Semicolon ';'")),
              ElevatedButton(
                  onPressed: _exportGridAsTSV,
                  child: const Text("Export to TSV (tab separated)")),
              ElevatedButton(
                  onPressed: _defaultExportGridAsCSVCompatibleWithExcel,
                  child: const Text("UTF-8 CSV compatible with MS Excel")),
              ElevatedButton(
                  onPressed: _defaultExportGridAsCSVFakeExcel,
                  child: const Text("Fake MS Excel .xls export")),
            ],
          ),
        ),
      ),
    );
  }
}
