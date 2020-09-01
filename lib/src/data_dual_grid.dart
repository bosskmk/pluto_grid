part of '../pluto_grid.dart';

typedef PlutoDualOnSelectedEventCallback = void Function(
    PlutoDualOnSelectedEvent event);

class PlutoDualOnSelectedEvent {
  PlutoOnSelectedEvent gridA;
  PlutoOnSelectedEvent gridB;

  PlutoDualOnSelectedEvent({
    this.gridA,
    this.gridB,
  });
}

class PlutoDualGridProps {
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final PlutoOnLoadedEventCallback onLoaded;
  final PlutoOnChangedEventCallback onChanged;
  final CreateHeaderCallBack createHeader;
  final CreateFooterCallBack createFooter;

  PlutoDualGridProps({
    this.columns,
    this.rows,
    this.onLoaded,
    this.onChanged,
    this.createHeader,
    this.createFooter,
  });
}

class PlutoDualGrid extends StatefulWidget {
  final PlutoDualGridProps gridPropsA;
  final PlutoDualGridProps gridPropsB;
  final PlutoMode mode;
  final PlutoDualOnSelectedEventCallback onSelected;

  PlutoDualGrid({
    this.gridPropsA,
    this.gridPropsB,
    this.mode,
    this.onSelected,
  });

  @override
  _PlutoDualGridState createState() => _PlutoDualGridState();
}

class _PlutoDualGridState extends State<PlutoDualGrid> {
  final FocusScopeNode _focusNodeA = FocusScopeNode();
  final FocusScopeNode _focusNodeB = FocusScopeNode();

  final _changeFocusSubject = ReplaySubject<bool>();

  FocusScopeNode _currentFocusNode;
  bool _isFocusA;

  PlutoStateManager stateManagerA;
  PlutoStateManager stateManagerB;

  @override
  void dispose() {
    _focusNodeA.dispose();
    _focusNodeB.dispose();

    _changeFocusSubject.close();

    super.dispose();
  }

  @override
  void initState() {
    _handleChangeFocusNode(true);

    _changeFocusSubject
        .debounceTime(Duration(milliseconds: 4))
        .listen(_handleChangeFocusNode);

    super.initState();
  }

  void _handleChangeFocusNode(bool isNodeAFocused) {
    if (_isFocusA == isNodeAFocused) {
      return;
    }

    setState(() {
      if (isNodeAFocused) {
        _currentFocusNode = _focusNodeA;
        _isFocusA = true;
      } else {
        _currentFocusNode = _focusNodeB;
        _isFocusA = false;
      }
    });
  }

  Widget _buildGrid({
    PlutoDualGridProps props,
    PlutoMode mode,
    FocusNode focusNode,
    bool canRequestFocus,
    BoxConstraints size,
    bool isGridA,
  }) {
    return FocusScope(
      node: focusNode,
      canRequestFocus: canRequestFocus,
      child: SizedBox(
        width: size.maxWidth / 2,
        child: PlutoGrid.popup(
          columns: props.columns,
          rows: props.rows,
          mode: mode,
          onLoaded: (PlutoOnLoadedEvent event) {
            if (isGridA) {
              stateManagerA = event.stateManager;
            } else {
              stateManagerB = event.stateManager;
            }

            event.stateManager.addListener(() {
              _changeFocusSubject.add(isGridA);
            });

            event.stateManager.keyManager.subject.stream
                .listen((KeyManagerEvent keyManagerEvent) {
              if (keyManagerEvent.event.runtimeType == RawKeyDownEvent) {
                if (keyManagerEvent.isCtrlLeft) {
                  _changeFocusSubject.add(true);
                } else if (keyManagerEvent.isCtrlRight) {
                  _changeFocusSubject.add(false);
                }
              }
            });

            if (props.onLoaded != null) {
              props.onLoaded(event);
            }
          },
          onChanged: props.onChanged,
          onSelected: (PlutoOnSelectedEvent event) {
            widget.onSelected(
              PlutoDualOnSelectedEvent(
                gridA: PlutoOnSelectedEvent(
                  row: stateManagerA.currentRow,
                  cell: stateManagerA.currentCell,
                ),
                gridB: PlutoOnSelectedEvent(
                  row: stateManagerB.currentRow,
                  cell: stateManagerB.currentCell,
                ),
              ),
            );
          },
          createHeader: props.createHeader,
          createFooter: props.createFooter,
        ),
      ),
    );
  }

  // todo : Ignore change focus when grid is resized.
  // todo : Change focus even when the grid is clicked but the changeNotify event does not occur.

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_currentFocusNode);

    return LayoutBuilder(builder: (ctx, size) {
      return Row(
        children: [
          _buildGrid(
            props: widget.gridPropsA,
            mode: widget.mode,
            focusNode: _focusNodeA,
            canRequestFocus: _isFocusA,
            size: size,
            isGridA: true,
          ),
          _buildGrid(
            props: widget.gridPropsB,
            mode: widget.mode,
            focusNode: _focusNodeB,
            canRequestFocus: !_isFocusA,
            size: size,
            isGridA: false,
          ),
        ],
      );
    });
  }
}
