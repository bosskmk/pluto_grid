part of '../../pluto_grid.dart';

class PlutoLoading extends StatelessWidget {
  final Color backgroundColor;
  final Color indicatorColor;
  final String indicatorText;
  final double indicatorSize;

  PlutoLoading({
    this.backgroundColor,
    this.indicatorColor,
    this.indicatorText,
    this.indicatorSize,
  });

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
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white,
              border: Border.all(color: indicatorColor ?? Colors.black),
            ),
            child: Text(
              indicatorText ?? 'Loading...',
              style: TextStyle(
                color: indicatorColor ?? Colors.black,
                fontSize: indicatorSize ?? 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
