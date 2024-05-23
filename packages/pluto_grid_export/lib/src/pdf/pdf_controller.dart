import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

/// Abstract class for PDF conversion.
abstract class PdfController {
  Future<Uint8List> generatePdf() async {
    final doc = Document(
      creator: getDocumentCreator(),
      title: getDocumentTitle(),
      theme: getThemeData(),
    );

    doc.addPage(
      MultiPage(
        pageFormat: getPageFormat(),
        orientation: getPageOrientation(),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        header: (context) => getHeader(context),
        footer: (context) => getFooter(context),
        build: (Context context) => exportInternal(context),
      ),
    );
    return doc.save();
  }

  /// It should return the page format of the PDF to be created.
  PdfPageFormat getPageFormat();

  /// The title of the PDF to be created should be returned.
  String getDocumentTitle();

  /// The name of the creator of the PDF to be created should be returned.
  String getDocumentCreator();

  /// The header widget of the PDF to be created should be implemented and returned.
  Widget getHeader(Context context);

  /// It should implement and return the footer widget of the PDF to be generated.
  Widget getFooter(Context context);

  /// Implement and return a list of PDFs to be created.
  List<Widget> exportInternal(Context context);

  /// The PageOrientation of the PDF to be created should be returned.
  PageOrientation getPageOrientation();

  /// The ThemeData of the PDF to be created should be returned.
  ThemeData getThemeData();
}
