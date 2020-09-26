part of '../../../pluto_grid.dart';

class NumberCellWidget extends StatefulWidget implements _TextBaseMixinImpl {
  final PlutoStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;

  NumberCellWidget({
    this.stateManager,
    this.cell,
    this.column,
  });

  @override
  _NumberCellWidgetState createState() => _NumberCellWidgetState();
}

class _NumberCellWidgetState extends State<NumberCellWidget>
    with _TextBaseMixin<NumberCellWidget> {
  int decimalRange;

  bool activatedNegative;

  @override
  void initState() {
    super.initState();

    decimalRange = widget.column.type.number.decimalRange();

    activatedNegative = widget.column.type.number.negative;
  }

  @override
  Widget build(BuildContext context) {
    _cellFocus.requestFocus();

    return _buildTextField(
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        DecimalTextInputFormatter(
          decimalRange: decimalRange,
          activatedNegativeValues: activatedNegative,
        ),
      ],
    );
  }
}

// https://stackoverflow.com/questions/54454983/allow-only-two-decimal-number-in-flutter-input
class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({
    int decimalRange,
    bool activatedNegativeValues,
  }) : assert(decimalRange == null || decimalRange >= 0,
            'DecimalTextInputFormatter declaration error') {
    String dp = (decimalRange != null && decimalRange > 0)
        ? "([.][0-9]{0,$decimalRange}){0,1}"
        : "";
    String num = "[0-9]*$dp";

    if (activatedNegativeValues) {
      _exp = new RegExp("^((((-){0,1})|((-){0,1}[0-9]$num))){0,1}\$");
    } else {
      _exp = new RegExp("^($num){0,1}\$");
    }
  }

  RegExp _exp;

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
