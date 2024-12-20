import 'package:flutter/material.dart';

class PlutoScaledCheckbox extends StatelessWidget {
  final bool? value;

  final Function(bool? changed) handleOnChanged;

  final bool tristate;

  final double scale;

  final Color? unselectedColor;

  final Color? activeColor;

  final Color? checkColor;

  const PlutoScaledCheckbox({
    super.key,
    required this.value,
    required this.handleOnChanged,
    this.tristate = false,
    this.scale = 1.0,
    this.unselectedColor,
    this.activeColor,
    this.checkColor,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Checkbox(
        value: value,
        tristate: tristate,
        onChanged: handleOnChanged,
      ),
    );
  }
}
