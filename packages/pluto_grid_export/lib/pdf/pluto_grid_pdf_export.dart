import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid_export/pdf/generic_pdf_controller.dart';

import '../abstract_text_export.dart';

class PlutoGridDefaultPdfExport extends AbstractTextExport {
  PlutoGridDefaultPdfExport({
    required this.title,
    this.creator,
    this.format,
  });

  final String title;
  final String? creator;
  PdfPageFormat? format;

  @override
  Future<Uint8List> export(PlutoGridStateManager state) async {
    return GenericPdfController(
      title: title,
      creator: creator ?? "https://pub.dev/packages/pluto_grid",
      format: format ?? PdfPageFormat.a4.landscape,
      columns: getColumnTitles(state),
      rows: mapStateToListOfRows(state),
    ).generatePdf();
  }

  String getFilename() {
    return "$title-${DateTime.now().millisecondsSinceEpoch}.pdf";
  }
}
