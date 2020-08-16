part of pluto_grid;

class ShadowLine extends StatelessWidget {
  final Axis axis;

  const ShadowLine(this.axis);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: axis == Axis.vertical ? 1 : 0,
      height: axis == Axis.horizontal ? 1 : 0,
      decoration: BoxDecoration(
        color: Colors.black38,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(3, 3), // changes position of shadow
          ),
        ],
      ),
    );
  }
}
