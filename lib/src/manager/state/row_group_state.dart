import 'package:collection/collection.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IRowGroupState {
  bool get hasRowGroups;

  List<PlutoRowGroup> get rowGroups;
}

mixin RowGroupState implements IPlutoGridState {
  @override
  bool get hasRowGroups =>
      refColumns.where((element) => element.enableRowGroup).isNotEmpty;

  @override
  List<PlutoRowGroup> get rowGroups {
    final groupedColumns = refColumns.where(
      (element) => element.enableRowGroup,
    );

    groupByColumn(PlutoColumn column, List<PlutoRow> rows) {
      return groupBy(rows, (PlutoRow row) => row.cells[column.field]!.value);
    }

    makeRowGroup({
      required List<PlutoColumn> columns,
      required List<PlutoRow> rows,
    }) {
      final List<PlutoRowGroup> rowGroups = [];

      final columnsIterator = columns.iterator;

      columnsIterator.moveNext();

      final groupColumn = columnsIterator.current;

      final groupRows = groupByColumn(groupColumn, rows);

      final isLast = !columnsIterator.moveNext();

      groupRows.forEach((key, value) {
        rowGroups.add(PlutoRowGroup(
          groupColumn: groupColumn,
          title: key,
          subGroups: isLast
              ? []
              : makeRowGroup(
                  columns: columns.sublist(1),
                  rows: value,
                ),
          rows: isLast ? value : [],
        ));
      });

      return rowGroups;
    }

    final rowGroups =
        makeRowGroup(columns: groupedColumns.toList(), rows: refRows);

    return rowGroups;
  }
}
