import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../abstract_text_export.dart';
import 'generic_pdf_controller.dart';

/// PDF exporter for PlutoGrid
///
/// [themeData] Attributes for custom fonts.
///
/// import 'package:pluto_grid_export/pluto_grid_export.dart' as pluto_grid_export;
///
/// final themeData = pluto_grid_export.ThemeData.withFont(
///   base: pluto_grid_export.Font.ttf(
///     await rootBundle.load('assets/fonts/open_sans/OpenSans-Regular.ttf'),
///   ),
///   bold: pluto_grid_export.Font.ttf(
///     await rootBundle.load('assets/fonts/open_sans/OpenSans-Bold.ttf'),
///   ),
/// );
class PlutoGridDefaultPdfExport extends AbstractTextExport {
  PlutoGridDefaultPdfExport({
    required this.title,
    this.creator,
    this.format,
    this.themeData,
  });

  final String title;
  final String? creator;
  PdfPageFormat? format;
  ThemeData? themeData;

  @override
  Future<Uint8List> export(PlutoGridStateManager state) async {
    return GenericPdfController(
      title: title,
      creator: creator ?? "https://pub.dev/packages/pluto_grid",
      format: format ?? PdfPageFormat.a4.landscape,
      columns: getColumnTitles(state),
      rows: mapStateToListOfRows(state),
      themeData: themeData,
    ).generatePdf();
  }

  String getFilename() {
    return "$title-${DateTime.now().millisecondsSinceEpoch}.pdf";
  }
}
