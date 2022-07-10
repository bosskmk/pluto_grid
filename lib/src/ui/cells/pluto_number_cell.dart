import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'text_cell.dart';

class PlutoNumberCell extends StatefulWidget implements TextCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoNumberCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    Key? key,
  }) : super(key: key);

  @override
  PlutoNumberCellState createState() => PlutoNumberCellState();
}

class PlutoNumberCellState extends State<PlutoNumberCell>
    with TextCellState<PlutoNumberCell> {
  int? decimalRange;

  bool? activatedNegative;

  bool? allowFirstDot;

  @override
  TextInputType get keyboardType => TextInputType.number;

  @override
  List<TextInputFormatter>? get inputFormatters => [
        DecimalTextInputFormatter(
          decimalRange: decimalRange,
          activatedNegativeValues: activatedNegative!,
          allowFirstDot: allowFirstDot!,
        ),
      ];

  @override
  void initState() {
    super.initState();

    decimalRange = widget.column.type.number!.decimalPoint;

    activatedNegative = widget.column.type.number!.negative;

    allowFirstDot = widget.column.type.number!.allowFirstDot;
  }
}

// https://stackoverflow.com/questions/54454983/allow-only-two-decimal-number-in-flutter-input
class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({
    int? decimalRange,
    required bool activatedNegativeValues,
    required bool allowFirstDot,
  }) : assert(decimalRange == null || decimalRange >= 0,
            'DecimalTextInputFormatter declaration error') {
    String dp = (decimalRange != null && decimalRange > 0)
        ? '([.][0-9]{0,$decimalRange}){0,1}'
        : '';
    String num = '[0-9]*$dp';

    if (activatedNegativeValues) {
      final firstSymbols = allowFirstDot ? '[-.]' : '[-]';

      _exp = RegExp(
        '^(((($firstSymbols){0,1})|(($firstSymbols){0,1}[0-9]$num))){0,1}\$',
      );
    } else {
      _exp = RegExp('^($num){0,1}\$');
    }
  }

  late RegExp _exp;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_exp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
