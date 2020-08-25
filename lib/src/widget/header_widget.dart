part of '../../pluto_grid.dart';

enum MenuItem { FixedLeft, FixedRight }

class HeaderWidget extends StatefulWidget {
  final PlutoStateManager stateManager;
  final PlutoColumn column;

  HeaderWidget({
    @required this.stateManager,
    @required this.column,
  }) : super(key: column._key);

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  PlutoColumnSort _sort;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    _sort = widget.column.sort;

    widget.stateManager.addListener(changeStateListener);

    super.initState();
  }

  void changeStateListener() {
    final changedColumn = widget.stateManager.columns
        .firstWhere((element) => element._key == widget.column._key);

    if (_sort != changedColumn.sort) {
      setState(() {
        _sort = changedColumn.sort;
      });
    }
  }

  void _showContextMenu(BuildContext context, Offset position) async {
    // todo : 아래 GestureDetector 의 onTapDown 이벤트가 클릭을 빨리하면 동작하지 않아 null
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
          value: MenuItem.FixedLeft,
          child: widget.column.fixed.isFixed == true
              ? const Text('고정 해제')
              : const Text('좌측 고정'),
        ),
        if (widget.column.fixed.isFixed != true)
          PopupMenuItem(
            value: MenuItem.FixedRight,
            child: widget.column.fixed.isFixed == true
                ? const Text('고정 해제')
                : const Text('우측 고정'),
          ),
      ],
    );

    switch (selectedMenu) {
      case MenuItem.FixedLeft:
        widget.stateManager
            .toggleFixedColumn(widget.column._key, PlutoColumnFixed.Left);
        break;
      case MenuItem.FixedRight:
        widget.stateManager
            .toggleFixedColumn(widget.column._key, PlutoColumnFixed.Right);
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
              widget.stateManager
                  .moveColumn(widget.column._key, dragDetails.offset.dx);
            },
            feedback: Container(
              width: widget.column.width,
              height: widget.stateManager.style.rowHeight,
              padding: const EdgeInsets.all(PlutoDefaultSettings.cellPadding),
              decoration: BoxDecoration(
                color: Colors.black26,
              ),
              child: Text(
                widget.column.title,
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
                widget.stateManager.toggleSortColumn(widget.column._key);
              },
              child: Container(
                width: widget.column.width,
                height: widget.stateManager.style.rowHeight,
                padding: const EdgeInsets.all(PlutoDefaultSettings.cellPadding),
                child: Text(
                  widget.column.title,
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
          top: 2,
          right: -6,
          child: GestureDetector(
            onTapDown: (TapDownDetails details) {
              _tapDownPosition = details.globalPosition;
            },
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              _currentPosition = details.localPosition;
            },
            onHorizontalDragEnd: (DragEndDetails details) {
              widget.stateManager
                  .resizeColumn(widget.column._key, _currentPosition.dx - 20);
            },
            child: Transform.rotate(
              angle: 90 * pi / 180,
              child: IconButton(
                icon: HeaderIcon(widget.column.sort),
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
