part of '../../pluto_grid.dart';

class ShadowContainer extends StatelessWidget {
  final double width;

  final double height;

  final EdgeInsetsGeometry padding;

  final Color backgroundColor;

  final Color borderColor;

  final AlignmentGeometry alignment;

  final Widget child;

  const ShadowContainer({
    Key key,
    @required this.width,
    @required this.height,
    @required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: PlutoDefaultSettings.cellPadding,
    ),
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFA1A5AE),
    this.alignment = Alignment.centerLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Align(
        alignment: alignment,
        child: child,
      ),
    );
  }
}
