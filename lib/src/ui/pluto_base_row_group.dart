import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoBaseRowGroup extends StatefulWidget {
  final PlutoGridStateManager stateManager;

  final PlutoRowGroup rowGroup;

  final List<PlutoColumn> columns;

  const PlutoBaseRowGroup({
    required this.stateManager,
    required this.rowGroup,
    required this.columns,
    Key? key,
  }) : super(key: key);

  @override
  State<PlutoBaseRowGroup> createState() => _PlutoBaseRowGroupState();
}

class _PlutoBaseRowGroupState extends State<PlutoBaseRowGroup> {
  double _heightFactor = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: widget.stateManager.rowTotalHeight,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: PlutoGridSettings.rowBorderWidth,
                color: widget.stateManager.configuration!.borderColor,
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                onPressed: () {
                  setState(() {
                    _heightFactor = _heightFactor == 0 ? 1 : 0;
                  });
                },
              ),
              Text(widget.rowGroup.title),
            ],
          ),
        ),
        ClipRect(
          child: Align(
            heightFactor: _heightFactor,
            alignment: Alignment.topLeft,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.rowGroup.hasSubGroups
                  ? widget.rowGroup.subGroups.length
                  : widget.rowGroup.rows.length,
              itemBuilder: (_, i) {
                return widget.rowGroup.hasSubGroups
                    ? PlutoBaseRowGroup(
                        stateManager: widget.stateManager,
                        rowGroup: widget.rowGroup.subGroups[i],
                        columns: widget.columns)
                    : PlutoBaseRow(
                        stateManager: widget.stateManager,
                        rowIdx: 0,
                        row: widget.rowGroup.rows[i],
                        columns: widget.columns,
                      );
              },
            ),
          ),
        ),
      ],
    );
  }
}
