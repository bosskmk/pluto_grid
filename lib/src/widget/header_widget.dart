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

    final Color textColor =
        widget.stateManager.configuration.cellTextStyle.color;

    final Color backgroundColor =
        widget.stateManager.configuration.activatedColor;

    final buildTextItem = (String text) {
      return Text(
        text,
        style: TextStyle(
          color: textColor,
        ),
      );
    };

    final MenuItem selectedMenu = await showMenu<MenuItem>(
      context: context,
      color: backgroundColor,
      position: RelativeRect.fromRect(
          position & Size(40, 40), Offset.zero & overlay.size),
      items: [
        PopupMenuItem(
          value: MenuItem.FixedLeft,
          child: widget.column.fixed.isFixed == true
              ? buildTextItem('Unfix')
              : buildTextItem('ToLeft'),
        ),
        if (widget.column.fixed.isFixed != true)
          PopupMenuItem(
            value: MenuItem.FixedRight,
            child: widget.column.fixed.isFixed == true
                ? buildTextItem('Unfix')
                : buildTextItem('ToRight'),
          ),
        PopupMenuItem(
          value: MenuItem.AutoSize,
          child: buildTextItem('AutoSize'),
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
          style: widget.stateManager.configuration.cellTextStyle,
          text: maxValue,
        );

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

  Widget _buildDraggable(Widget child) {
    return Draggable(
      onDragEnd: (dragDetails) {
        widget.stateManager
            .moveColumn(widget.column._key, dragDetails.offset.dx);
      },
      feedback: Container(
        width: widget.column.width,
        height: PlutoDefaultSettings.rowHeight,
        padding: const EdgeInsets.all(PlutoDefaultSettings.cellPadding),
        decoration: BoxDecoration(
          color: Colors.black26,
        ),
        child: Text(
          widget.column.title,
          style: widget.stateManager.configuration.headerTextStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          softWrap: false,
        ),
      ),
      child: child,
    );
  }

  Widget _buildHeader() {
    Widget _header = Container(
      width: widget.column.width,
      height: PlutoDefaultSettings.rowHeight,
      padding: const EdgeInsets.all(PlutoDefaultSettings.cellPadding),
      decoration: widget.stateManager.configuration.enableColumnBorder
          ? BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: widget.stateManager.configuration.borderColor,
                  width: 1.0,
                ),
              ),
            )
          : BoxDecoration(),
      child: Text(
        widget.column.title,
        style: widget.stateManager.configuration.headerTextStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false,
      ),
    );

    return widget.column.enableSorting
        ? InkWell(
            onTap: () {
              widget.stateManager.toggleSortColumn(widget.column._key);
            },
            child: _header,
          )
        : _header;
  }

  @override
  Widget build(BuildContext context) {
    Offset _currentPosition;

    Offset _tapDownPosition;

    return Stack(
      children: [
        Positioned(
          child: widget.column.enableDraggable
              ? _buildDraggable(_buildHeader())
              : _buildHeader(),
        ),
        if (widget.column.enableContextMenu)
          Positioned(
            top: -2,
            right: -5,
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
              child: IconButton(
                icon: HeaderIcon(
                  sort: widget.column.sort,
                  color: widget.stateManager.configuration.iconColor,
                ),
                iconSize: 18,
                onPressed: () {
                  _showContextMenu(context, _tapDownPosition);
                },
              ),
            ),
          ),
      ],
    );
  }
}

class HeaderIcon extends StatelessWidget {
  final PlutoColumnSort sort;
  final Color color;

  HeaderIcon({
    this.sort,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    switch (sort) {
      case PlutoColumnSort.Ascending:
        return Transform.rotate(
          angle: 90 * pi / 90,
          child: const Icon(
            Icons.sort,
            color: Colors.green,
          ),
        );
      case PlutoColumnSort.Descending:
        return const Icon(
          Icons.sort,
          color: Colors.red,
        );
      default:
        return Icon(
          Icons.menu,
          color: color ?? Colors.black26,
        );
    }
  }
}
