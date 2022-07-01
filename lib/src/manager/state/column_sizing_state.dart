import 'package:pluto_grid/pluto_grid.dart';

abstract class IColumnSizingState {
  PlutoGridColumnSizeConfig get columnSizeConfig;

  PlutoAutoSizeMode get columnsAutoSizeMode;

  PlutoResizeMode get columnsResizeMode;

  bool get enableColumnsAutoSize;

  bool get activatedColumnsAutoSize;

  void activateColumnsAutoSize();

  void deactivateColumnsAutoSize();

  PlutoAutoSize getColumnsAutoSizeHelper({
    required Iterable<PlutoColumn> columns,
    required double maxWidth,
  });

  PlutoResize getColumnsResizeHelper({
    required List<PlutoColumn> columns,
    required PlutoColumn column,
    required double offset,
  });
}

mixin ColumnSizingState implements IPlutoGridState {
  @override
  PlutoGridColumnSizeConfig get columnSizeConfig =>
      configuration!.columnSizeConfig;

  @override
  PlutoAutoSizeMode get columnsAutoSizeMode => columnSizeConfig.autoSizeMode;

  @override
  PlutoResizeMode get columnsResizeMode => columnSizeConfig.resizeMode;

  @override
  bool get enableColumnsAutoSize => !columnsAutoSizeMode.isNone;

  @override
  bool get activatedColumnsAutoSize =>
      enableColumnsAutoSize && _activatedColumnsAutoSize != false;

  bool? _activatedColumnsAutoSize;

  @override
  void activateColumnsAutoSize() {
    _activatedColumnsAutoSize = true;
  }

  @override
  void deactivateColumnsAutoSize() {
    _activatedColumnsAutoSize = false;
  }

  @override
  PlutoAutoSize getColumnsAutoSizeHelper({
    required Iterable<PlutoColumn> columns,
    required double maxWidth,
  }) {
    double? scale;

    if (columnsAutoSizeMode.isScale) {
      final totalWidth = columns.fold<double>(0, (pre, e) => pre += e.width);

      scale = maxWidth / totalWidth;
    }

    return PlutoAutoSizeHelper.items(
      maxSize: maxWidth,
      length: columns.length,
      itemMinSize: PlutoGridSettings.minColumnWidth,
      mode: columnsAutoSizeMode,
      scale: scale,
    );
  }

  @override
  PlutoResize getColumnsResizeHelper({
    required List<PlutoColumn> columns,
    required PlutoColumn column,
    required double offset,
  }) {
    return PlutoResizeHelper.items<PlutoColumn>(
      offset: offset,
      items: columns,
      isMainItem: (e) => e.key == column.key,
      getItemSize: (e) => e.width,
      getItemMinSize: (e) => e.minWidth,
      setItemSize: (e, size) => e.width = size,
      mode: columnsResizeMode,
    );
  }
}
