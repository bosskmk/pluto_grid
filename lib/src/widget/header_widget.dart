part of pluto_grid;

enum MenuItem { Fixed }

class HeaderWidget extends StatelessWidget {
  final PlutoStateManager stateManager;
  final PlutoColumn column;

  HeaderWidget({
    @required this.stateManager,
    @required this.column,
  }) : super(key: column._key);

  void _showContextMenu(BuildContext context, Offset position) async {
    // TODO : 아래 GestureDetector 의 onTapDown 이벤트가 클릭을 빨리하면 동작하지 않아 null
    if (position == null) {
      return;
    }
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    final MenuItem selectedMenu = await showMenu<MenuItem>(
      context: context,
      position: RelativeRect.fromRect(
          position & Size(40, 40), Offset.zero & overlay.size),
      items: [
        PopupMenuItem(
          value: MenuItem.Fixed,
          child: column.fixed.isFixed == true
              ? const Text('고정 해제')
              : const Text('왼쪽 고정'),
        ),
      ],
    );

    switch (selectedMenu) {
      case MenuItem.Fixed:
        stateManager.toggleFixedColumn(column._key);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Offset _currentPosition;
    Offset _tapDownPosition;
    return Stack(
      children: [
        Positioned(
          child: Draggable(
            onDragEnd: (dragDetails) {
//              handleMoveColumn(dragDetails.offset.dx);
            },
            feedback: Container(
              width: column.width,
              height: stateManager.style.rowHeight,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black26,
              ),
              child: Text(
                column.title,
                style: const TextStyle(
                  color: Colors.black,
                  decoration: TextDecoration.none,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
              ),
            ),
            child: InkWell(
              onTap: () {
//                handleSorted();
              },
              child: Container(
                width: column.width,
                height: stateManager.style.rowHeight,
                padding: const EdgeInsets.all(20),
                child: Text(
                  column.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: -6,
          child: GestureDetector(
            onTapDown: (TapDownDetails details) {
              _tapDownPosition = details.globalPosition;
            },
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              _currentPosition = details.localPosition;
            },
            onHorizontalDragEnd: (DragEndDetails details) {
//              handleResizeColumn(_currentPosition.dx - 20);
            },
            child: Transform.rotate(
              angle: 90 * pi / 180,
              child: IconButton(
                icon: HeaderIcon(null),
                iconSize: 18,
                onPressed: () {
                  _showContextMenu(context, _tapDownPosition);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HeaderIcon extends StatelessWidget {
  final PlutoColumnSort sort;

  HeaderIcon(this.sort);

  @override
  Widget build(BuildContext context) {
    switch (sort) {
      case PlutoColumnSort.Ascending:
        return const Icon(
          Icons.arrow_back,
          color: Colors.green,
        );
      case PlutoColumnSort.Descending:
        return const Icon(
          Icons.arrow_forward,
          color: Colors.red,
        );
      default:
        return const Icon(
          Icons.vertical_align_center,
          color: Colors.black26,
        );
    }
  }
}
