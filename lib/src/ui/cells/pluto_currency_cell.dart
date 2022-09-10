import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'decimal_imput_formatter.dart';
import 'text_cell.dart';

class PlutoCurrencyCell extends StatefulWidget implements TextCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoCurrencyCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    Key? key,
  }) : super(key: key);

  @override
  PlutoCurrencyCellState createState() => PlutoCurrencyCellState();
}

class PlutoCurrencyCellState extends State<PlutoCurrencyCell>
    with TextCellState<PlutoCurrencyCell> {
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

    final numberColumn = widget.column.type.money!;

    decimalRange = 2;

    activatedNegative = true;

    allowFirstDot = true;

    decimalSeparator = numberColumn.currencyFormat.symbols.DECIMAL_SEP;

    inputFormatters = [
      DecimalTextInputFormatter(
        decimalRange: decimalRange,
        activatedNegativeValues: activatedNegative,
        allowFirstDot: allowFirstDot,
        decimalSeparator: decimalSeparator,
      ),
    ];

    keyboardType = TextInputType.numberWithOptions(
      decimal: true,
      signed: activatedNegative,
    );
  }
}