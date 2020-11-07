part of '../../../pluto_grid.dart';

class CustomCellWidget extends DefaultCellWidget implements _TextBaseMixinImpl {
  final PlutoStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;

  CustomCellWidget({
    this.stateManager,
    this.cell,
    this.column,
  });

  @override
  _CustomCellWidgetState createState() => _CustomCellWidgetState();
}

class _CustomCellWidgetState extends _DefaultCellWidgetState {

  _CustomCellWidgetState();

  Widget getCellWidget() {
    if (widget.column.hasRenderer) {
      return widget.column.renderer(PlutoColumnRendererContext(
        column: widget.column,
        rowIdx: widget.rowIdx,
        row: thisRow,
        cell: widget.cell,
        stateManager: widget.stateManager,
      ));
    }
    final type = widget.column.type as PlutoColumnTypeWidget;
    return type.buildWidget(widget.cell.value);
  }
}
