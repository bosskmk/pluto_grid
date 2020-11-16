part of '../../pluto_grid.dart';

class PlutoLoadingWidget extends StatelessWidget {
  final Color backgroundColor;
  final Color indicatorColor;
  final String indicatorText;
  final double indicatorSize;

  PlutoLoadingWidget({
    this.backgroundColor = Colors.white,
    this.indicatorColor = Colors.black,
    this.indicatorText = 'Loading...',
    this.indicatorSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.7,
            child: ColoredBox(
              color: backgroundColor,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: indicatorColor),
            ),
            child: Text(
              indicatorText,
              style: TextStyle(
                color: indicatorColor,
                fontSize: indicatorSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
