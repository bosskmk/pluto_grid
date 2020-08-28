part of '../../pluto_grid.dart';

enum MenuItem {
  FixedLeft,
  FixedRight,
  AutoSize,
}

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
    // The below GestureDetector's onTapDown event doesn't work if you click quickly, so it's null
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
              ? const Text('Unfix')
              : const Text('ToLeft'),
        ),
        if (widget.column.fixed.isFixed != true)
          PopupMenuItem(
            value: MenuItem.FixedRight,
            child: widget.column.fixed.isFixed == true
                ? const Text('Unfix')
                : const Text('ToRight'),
          ),
        PopupMenuItem(
          value: MenuItem.AutoSize,
          child: const Text('AutoSize'),
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
      case MenuItem.AutoSize:
        final String maxValue =
            widget.stateManager.rows.fold('', (previousValue, element) {
          final value = element.cells.entries
              .firstWhere((element) => element.key == widget.column.field)
              .value
              .value;

          if (previousValue.toString().length < value.toString().length) {
            return value.toString();
          }
          return previousValue.toString();
        });

        // Get size after rendering virtually
        // https://stackoverflow.com/questions/54351655/flutter-textfield-width-should-match-width-of-contained-text
        TextSpan textSpan = new TextSpan(
            style: PlutoDefaultSettings.cellTextStyle, text: maxValue);
        TextPainter textPainter = new TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        widget.stateManager.resizeColumn(
            widget.column._key,
            textPainter.width -
                widget.column.width +
                (PlutoDefaultSettings.cellPadding * 2) +
                10);
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
                style: PlutoDefaultSettings.headerTextStyle,
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
                  style: PlutoDefaultSettings.headerTextStyle,
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
