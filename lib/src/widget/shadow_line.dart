part of '../../pluto_grid.dart';

class ShadowLine extends StatelessWidget {
  final Axis axis;
  final bool reverse;

  const ShadowLine({
    this.axis,
    this.reverse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: axis == Axis.vertical ? 1 : 0,
      height: axis == Axis.horizontal ? 1 : 0,
      decoration: BoxDecoration(
        color: PlutoDefaultSettings.gridBorderColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 3,
            offset: reverse == true
                ? const Offset(-3, -3)
                : const Offset(3, 3), // changes position of shadow
          ),
        ],
      ),
    );
  }
}
