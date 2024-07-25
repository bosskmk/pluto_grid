import 'package:flutter/material.dart';

class PlutoScaledCheckbox extends StatelessWidget {
  final bool? value;

  final Function(bool? changed) handleOnChanged;

  final bool tristate;

  final double scale;

  final Color unselectedColor;

  final Color? semiSelectedColor;

  final Color? activeColor;

  final Color checkColor;

  final Color checkboxBorderColor;

  const PlutoScaledCheckbox({
    Key? key,
    required this.value,
    required this.handleOnChanged,
    this.tristate = false,
    this.scale = 1.0,
    this.unselectedColor = Colors.black26,
    this.semiSelectedColor = Colors.grey,
    this.activeColor = Colors.lightBlue,
    this.checkColor = const Color(0xFFDCF5FF),
    this.checkboxBorderColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fillColor = value == null
        ? tristate
            ? semiSelectedColor
            : unselectedColor
        : activeColor;

    return Transform.scale(
      scale: scale,
      child: Theme(
        data: ThemeData(
          unselectedWidgetColor: unselectedColor,
        ),
        child: Checkbox(
          value: value,
          tristate: tristate,
          onChanged: handleOnChanged,
          activeColor: fillColor,
          checkColor: checkColor,
          side: BorderSide(color: checkboxBorderColor),
        ),
      ),
    );
  }
}
