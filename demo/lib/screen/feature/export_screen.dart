// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid.dart';

// import 'package:pluto_grid_plus_export/pluto_grid_export.dart' as pluto_grid_export;

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class ExportScreen extends StatefulWidget {
  static const routeName = 'feature/export';

  const ExportScreen({super.key});

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
      title: 'Export / download as PDF or CSV',
      topTitle: 'Export / download as PDF or CSV',
      topContents: const [
        Text(
            'You can export grid contents as PDF or CSV with pluto_grid_export package from pub.dev.'),
        Text("The example doesn't actually download the file."),
        Text(
            'The file download part is implemented directly for each platform or is possible through a package such as FileSaver.'),
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
  });

  final PlutoGridStateManager stateManager;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  void _printToPdfAndShareOrSave() async {
    // final themeData = pluto_grid_export.ThemeData.withFont(
    //   base: pluto_grid_export.Font.ttf(
    //     await rootBundle.load('assets/fonts/open_sans/OpenSans-Regular.ttf'),
    //   ),
    //   bold: pluto_grid_export.Font.ttf(
    //     await rootBundle.load('assets/fonts/open_sans/OpenSans-Bold.ttf'),
    //   ),
    // );
    //
    // var plutoGridPdfExport = pluto_grid_export.PlutoGridDefaultPdfExport(
    //   title: "Pluto Grid Sample pdf print",
    //   creator: "Pluto Grid Rocks!",
    //   format: pluto_grid_export.PdfPageFormat.a4.landscape,
    //   themeData: themeData,
    // );
    //
    // await pluto_grid_export.Printing.sharePdf(
    //     bytes: await plutoGridPdfExport.export(widget.stateManager),
    //     filename: plutoGridPdfExport.getFilename());
  }

  // This doesn't works properly in systems different from Windows.
  // Disabled for now
  // void _printToPdfWithDialog() async {
  //   var originalFormat = PdfPageFormat.a4.landscape;
  //
  //   var plutoGridDefaultPdfExport = PlutoGridDefaultPdfExport(
  //       title: "Pluto Grid Sample pdf print",
  //       creator: "Pluto Grid Rocks!",
  //       format: originalFormat);
  //
  //   await Printing.layoutPdf(
  //       format: originalFormat,
  //       name: plutoGridDefaultPdfExport.getFilename(),
  //       onLayout: (PdfPageFormat format) async {
  //         // Update format onLayout
  //         plutoGridDefaultPdfExport.format = format;
  //         return plutoGridDefaultPdfExport.export(widget.stateManager);
  //       });
  // }

  void _defaultExportGridAsCSV() async {
    // String title = "pluto_grid_export";
    // var exported = const Utf8Encoder().convert(
    //     pluto_grid_export.PlutoGridExport.exportCSV(widget.stateManager));
    // await FileSaver.instance.saveFile("$title.csv", exported, ".csv");
  }

  void _defaultExportGridAsCSVCompatibleWithExcel() async {
    // String title = "pluto_grid_export";
    // var exportCSV =
    //     pluto_grid_export.PlutoGridExport.exportCSV(widget.stateManager);
    // var exported = const Utf8Encoder().convert(
    //     // FIX Add starting \u{FEFF} / 0xEF, 0xBB, 0xBF
    //     // This allows open the file in Excel with proper character interpretation
    //     // See https://stackoverflow.com/a/155176
    //     '\u{FEFF}$exportCSV');
    // await FileSaver.instance.saveFile("$title.csv", exported, ".csv");
  }

  void _defaultExportGridAsCSVFakeExcel() async {
    // String title = "pluto_grid_export";
    // var exportCSV =
    //     pluto_grid_export.PlutoGridExport.exportCSV(widget.stateManager);
    // var exported = const Utf8Encoder().convert(
    //     // FIX Add starting \u{FEFF} / 0xEF, 0xBB, 0xBF
    //     // This allows open the file in Excel with proper character interpretation
    //     // See https://stackoverflow.com/a/155176
    //     '\u{FEFF}$exportCSV');
    // await FileSaver.instance.saveFile("$title.xls", exported, ".xls");
  }

  // void _exportGridAsTSV() async {
  //   String title = "pluto_grid_export";
  //   var exported = const Utf8Encoder().convert(PlutoGridExport.exportCSV(
  //     widget.stateManager,
  //     fieldDelimiter: "\t",
  //   ));
  //   await FileSaver.instance.saveFile("$title.csv", exported, ".csv");
  // }

  void _defaultExportGridAsCSVWithSemicolon() async {
    // String title = "pluto_grid_export";
    // var exported =
    //     const Utf8Encoder().convert(pluto_grid_export.PlutoGridExport.exportCSV(
    //   widget.stateManager,
    //   fieldDelimiter: ";",
    // ));
    // await FileSaver.instance.saveFile("$title.csv", exported, ".csv");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: widget.stateManager.headerHeight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 10,
            children: [
              ElevatedButton(
                  onPressed: _printToPdfAndShareOrSave,
                  child: const Text("Print to PDF and Share")),

              // TODO This works only under Windows, disabled for now
              // ElevatedButton(
              //     onPressed: _printToPdfWithDialog,
              //     child: const Text("Print PDF with dialog (Windows only)")),
              ElevatedButton(
                  onPressed: _defaultExportGridAsCSV,
                  child: const Text("Export to CSV")),
              ElevatedButton(
                  onPressed: _defaultExportGridAsCSVWithSemicolon,
                  child: const Text("Export to CSV with Semicolon ';'")),
              // ElevatedButton(
              //     onPressed: _exportGridAsTSV,
              //     child: const Text("Export to TSV (tab separated)")),
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
