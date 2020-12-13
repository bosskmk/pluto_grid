part of '../../../pluto_grid.dart';

class PlutoColumnFilter extends _PlutoStatefulWidget {
  final PlutoStateManager stateManager;
  final PlutoColumn column;

  PlutoColumnFilter({
    this.stateManager,
    this.column,
  });

  @override
  _PlutoColumnFilterState createState() => _PlutoColumnFilterState();
}

abstract class _PlutoColumnFilterStateWithChange
    extends _PlutoStateWithChange<PlutoColumnFilter> {
  FocusNode focusNode;

  TextEditingController controller;

  List<PlutoRow> filterRows;

  String text;

  bool enabled;

  String get filterValue {
    return filterRows.isEmpty
        ? ''
        : filterRows.first.cells[FilterHelper.filterFieldValue].value;
  }

  bool get hasCompositeFilter {
    return filterRows.length > 1 ||
        widget.stateManager
            .filterRowsByField(FilterHelper.filterFieldAllColumns)
            .isNotEmpty;
  }

  @override
  initState() {
    super.initState();

    focusNode = FocusNode(onKey: handleOnKey);

    controller = TextEditingController(text: filterValue);
  }

  @override
  dispose() {
    focusNode.dispose();

    controller.dispose();

    super.dispose();
  }

  @override
  void onChange() {
    resetState((update) {
      filterRows = update<List<PlutoRow>>(
        filterRows,
        widget.stateManager.filterRowsByField(widget.column.field),
      );

      if (focusNode?.hasPrimaryFocus != true) {
        text = update<String>(text, filterValue);

        if (_changed) {
          controller?.text = text;
        }
      }

      enabled = update<bool>(
        enabled,
        widget.column.enableFilterMenuItem && !hasCompositeFilter,
      );
    });
  }

  bool handleOnKey(FocusNode node, RawKeyEvent event) {
    return true;
  }
}

class _PlutoColumnFilterState extends _PlutoColumnFilterStateWithChange {
  InputBorder get border => OutlineInputBorder(
        borderSide: BorderSide(
            color: widget.stateManager.configuration.borderColor, width: 0.0),
        borderRadius: BorderRadius.zero,
      );

  InputBorder get enabledBorder => OutlineInputBorder(
        borderSide: BorderSide(
            color: widget.stateManager.configuration.activatedBorderColor,
            width: 0.0),
        borderRadius: BorderRadius.zero,
      );

  Color get textFieldColor => enabled
      ? widget.stateManager.configuration.cellColorInEditState
      : widget.stateManager.configuration.cellColorInReadOnlyState;

  void handleOnTap() {
    widget.stateManager.setKeepFocus(false);
  }

  void handleOnChanged(String changed) {
    widget.stateManager.eventManager.addEvent(
      PlutoChangeColumnFilterEvent(
        columnField: widget.column.field,
        filterType: PlutoFilterTypeContains(),
        filterValue: changed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.column.width,
      height: widget.stateManager.columnHeight,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Align(
        alignment: Alignment.center,
        child: Stack(
          children: [
            TextField(
              focusNode: focusNode,
              controller: controller,
              enabled: enabled,
              style: widget.stateManager.configuration.cellTextStyle,
              onTap: handleOnTap,
              onChanged: handleOnChanged,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: textFieldColor,
                border: border,
                enabledBorder: border,
                focusedBorder: enabledBorder,
                contentPadding: const EdgeInsets.symmetric(vertical: 5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
