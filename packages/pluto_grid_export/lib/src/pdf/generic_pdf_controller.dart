import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import 'pdf_controller.dart';

/// GenericPdfController
class GenericPdfController extends PdfController {
  static const PdfColor borderColor = PdfColors.black;
  static const PdfColor headerBackground = PdfColors.teal100;
  static const PdfColor oddRowColor = PdfColors.grey100;
  static const PdfColor baseTextColor = PdfColors.black;
  static const PdfColor baseCellColor = PdfColors.white;

  GenericPdfController({
    required this.title,
    required this.creator,
    required this.format,
    required this.columns,
    required this.rows,
    this.header,
    this.footer,
    this.themeData,
  });

  final Widget? header;
  final Widget? footer;
  final String title;
  final String creator;
  final PdfPageFormat format;
  final List<String> columns;
  final List<List<String?>> rows;
  final ThemeData? themeData;

  @override
  PageOrientation getPageOrientation() {
    return PageOrientation.landscape;
  }

  @override
  String getDocumentCreator() {
    return creator;
  }

  @override
  String getDocumentTitle() {
    return title;
  }

  @override
  PdfPageFormat getPageFormat() {
    return format;
  }

  @override
  Widget getHeader(Context context) {
    String title = getDocumentTitle();

    return header ??
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        );
  }

  @override
  List<Widget> exportInternal(Context context) {
    return [
      _table(columns, rows),
    ];
  }

  Widget _table(List<String> columns, List<List<String?>> rows) {
    return TableHelper.fromTextArray(
      border: null,
      cellAlignment: Alignment.center,
      // [Resolved 3.8.1] https://github.com/DavBfr/dart_pdf/pull/1033 to replace "headerDecoration" with "headerCellDecoration"
      headerCellDecoration: BoxDecoration(
        color: headerBackground,
        border: Border.all(
          color: borderColor,
          width: 0.5,
        ),
      ),
      headerDecoration: BoxDecoration(
        color: headerBackground,
        border: Border.all(
          color: borderColor,
          width: 0.5,
        ),
      ),
      headerHeight: 25,
      cellHeight: 15,
      headerStyle: TextStyle(
        color: baseTextColor,
        fontSize: 7,
        fontWeight: FontWeight.bold,
      ),
      headerAlignment: Alignment.center,
      cellPadding: const EdgeInsets.all(1),
      cellStyle: const TextStyle(
        color: baseTextColor,
        fontSize: 8,
      ),
      oddRowDecoration: const BoxDecoration(color: oddRowColor),
      cellDecoration: (index, data, rowNum) => BoxDecoration(
        border: Border.all(
          color: borderColor,
          width: .5,
        ),
      ),
      headers: columns,
      data: rows,
    );
  }

  @override
  Widget getFooter(Context context) {
    return footer ??
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '# ${context.pageNumber}/${context.pagesCount}',
              ),
              Text(
                DateTime.now().toString(),
              ),
            ],
          ),
        );
  }

  @override
  ThemeData getThemeData() {
    if (themeData != null) {
      return themeData!;
    }

    return ThemeData.base();
  }
}
