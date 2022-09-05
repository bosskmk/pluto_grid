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
  late final int decimalRange;

  late final bool activatedNegative;

  late final bool allowFirstDot;

  late final String decimalSeparator;

  @override
  late final TextInputType keyboardType;

  @override
  late final List<TextInputFormatter>? inputFormatters;

  @override
  void initState() {
    super.initState();

    final numberColumn = widget.column.type.number!;

    decimalRange = numberColumn.decimalPoint;

    activatedNegative = numberColumn.negative;

    allowFirstDot = numberColumn.allowFirstDot;

    decimalSeparator = numberColumn.numberFormat.symbols.DECIMAL_SEP;

    inputFormatters = [
      DecimalTextInputFormatter(
        decimalRange: decimalRange,
        activatedNegativeValues: activatedNegative,
        allowFirstDot: allowFirstDot,
        decimalSeparator: decimalSeparator,
      ),
    ];

    keyboardType = TextInputType.numberWithOptions(
      decimal: decimalRange > 0,
      signed: activatedNegative,
    );
  }
}

// https://stackoverflow.com/questions/54454983/allow-only-two-decimal-number-in-flutter-input
class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({
    int? decimalRange,
    required bool activatedNegativeValues,
    required bool allowFirstDot,
    required String decimalSeparator,
  }) : assert(decimalRange == null || decimalRange >= 0,
            'DecimalTextInputFormatter declaration error') {
    String dp = (decimalRange != null && decimalRange > 0)
        ? '([$decimalSeparator][0-9]{0,$decimalRange}){0,1}'
        : '';
    String num = '[0-9]*$dp';

    if (activatedNegativeValues) {
      final firstSymbols = allowFirstDot ? '[-$decimalSeparator]' : '[-]';

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
