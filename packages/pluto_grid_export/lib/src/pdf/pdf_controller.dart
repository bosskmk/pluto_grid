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

  PdfPageFormat getPageFormat();

  String getDocumentTitle();

  String getDocumentCreator();

  Widget getHeader(Context context);

  Widget getFooter(Context context);

  List<Widget> exportInternal(Context context);

  PageOrientation getPageOrientation();

  ThemeData getThemeData();
}
