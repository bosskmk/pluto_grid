import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'mixin_text_cell.dart';

class PlutoNumberCell extends StatefulWidget implements AbstractMixinTextCell {
  final PlutoGridStateManager? stateManager;
  final PlutoCell? cell;
  final PlutoColumn? column;
  final PlutoRow? row;

  PlutoNumberCell({
    this.stateManager,
    this.cell,
    this.column,
    this.row,
  });

  @override
  _PlutoNumberCellState createState() => _PlutoNumberCellState();
}

class _PlutoNumberCellState extends State<PlutoNumberCell>
    with MixinTextCell<PlutoNumberCell> {
  int? decimalRange;

  bool? activatedNegative;

  @override
  void initState() {
    super.initState();

    decimalRange = widget.column!.type.number!.decimalRange();

    activatedNegative = widget.column!.type.number!.negative;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stateManager!.keepFocus) {
      cellFocus!.requestFocus();
    }

    return buildTextField(
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        DecimalTextInputFormatter(
          decimalRange: decimalRange,
          activatedNegativeValues: activatedNegative!,
        ),
      ],
    );
  }
}

// https://stackoverflow.com/questions/54454983/allow-only-two-decimal-number-in-flutter-input
class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({
    int? decimalRange,
    required bool activatedNegativeValues,
  }) : assert(decimalRange == null || decimalRange >= 0,
            'DecimalTextInputFormatter declaration error') {
    String dp = (decimalRange != null && decimalRange > 0)
        ? '([.][0-9]{0,$decimalRange}){0,1}'
        : '';
    String num = '[0-9]*$dp';

    if (activatedNegativeValues) {
      _exp = RegExp('^((((-){0,1})|((-){0,1}[0-9]$num))){0,1}\$');
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
