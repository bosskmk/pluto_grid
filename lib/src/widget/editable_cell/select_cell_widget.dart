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

  Icon icon = Icon(
    Icons.arrow_drop_down,
    color: Colors.black54,
  );

  @override
  void initState() {
    popupHeight = ((widget.column.type.selectItems.length + 1) *
            PlutoDefaultSettings.rowTotalHeight) +
        PlutoDefaultSettings.shadowLineSize +
        PlutoDefaultSettings.gridInnerSpacing;

    fieldOnSelected = widget.column.title;

    popupColumns = [
      PlutoColumn(
        title: widget.column.title,
        field: widget.column.title,
        type: PlutoColumnType.text(readOnly: true),
      )
    ];

    popupRows = widget.column.type.selectItems.map((dynamic item) {
      return PlutoRow(
        cells: {
          widget.column.title: PlutoCell(value: item),
        },
      );
    }).toList();

    super.initState();
  }
}
