part of '../../../pluto_grid.dart';

class SelectCellWidget extends StatefulWidget implements _PopupBaseMixinImpl {
  final PlutoStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;

  SelectCellWidget({
    this.stateManager,
    this.cell,
    this.column,
  });

  @override
  _SelectCellWidgetState createState() => _SelectCellWidgetState();
}

class _SelectCellWidgetState extends State<SelectCellWidget>
    with _PopupBaseMixin<SelectCellWidget> {
  List<PlutoColumn> popupColumns;

  List<PlutoRow> popupRows;

  Icon icon = const Icon(
    Icons.arrow_drop_down,
  );

  @override
  void initState() {
    super.initState();

    popupHeight = ((widget.column.type.select.items.length + 1) *
            PlutoDefaultSettings.rowTotalHeight) +
        PlutoDefaultSettings.shadowLineSize +
        PlutoDefaultSettings.gridInnerSpacing;

    fieldOnSelected = widget.column.title;

    popupColumns = [
      PlutoColumn(
        title: widget.column.title,
        field: widget.column.title,
        type: PlutoColumnType.text(readOnly: true),
        formatter: widget.column.formatter,
      )
    ];

    popupRows = widget.column.type.select.items.map((dynamic item) {
      return PlutoRow(
        cells: {
          widget.column.title: PlutoCell(value: item),
        },
      );
    }).toList();
  }

  @override
  void _onLoaded(PlutoOnLoadedEvent event) {
    event.stateManager.setSelectingMode(PlutoSelectingMode.None);

    super._onLoaded(event);
  }
}
