import 'package:flutter/material.dart';

class PlutoLoading extends StatelessWidget {
  final Color? backgroundColor;
  final Color? indicatorColor;
  final String? text;
  final TextStyle? textStyle;

  const PlutoLoading({
    this.backgroundColor,
    this.indicatorColor,
    this.text,
    this.textStyle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.7,
            child: ColoredBox(
              color: backgroundColor ?? Colors.white,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                backgroundColor: backgroundColor ?? Colors.white,
                color: indicatorColor ?? Colors.lightBlue,
                strokeWidth: 2,
              ),
              const SizedBox(height: 10),
              Text(
                text ?? 'Loading',
                style: textStyle ??
                    const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
