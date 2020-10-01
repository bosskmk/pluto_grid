import 'package:flutter/material.dart';
import 'package:rainbow_color/rainbow_color.dart';

class PlutoTextColorAnimation extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  PlutoTextColorAnimation({
    this.text,
    this.fontSize,
    this.fontWeight,
  });

  @override
  _PlutoTextColorAnimationState createState() =>
      _PlutoTextColorAnimationState();
}

class _PlutoTextColorAnimationState extends State<PlutoTextColorAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<Color> _colorAnim;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(seconds: 5), vsync: this);
    _colorAnim = RainbowColorTween([
      Colors.white,
      Color(0xFF33BDE5),
      Colors.white,
    ]).animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reset();
          controller.forward();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: TextStyle(
        color: _colorAnim.value,
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
      ),
    );
  }
}
