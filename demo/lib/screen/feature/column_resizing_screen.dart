import 'package:demo/dummy_data/development.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class ColumnResizingScreen extends StatefulWidget {
  static const routeName = 'feature/column-resizing';

  const ColumnResizingScreen({Key? key}) : super(key: key);

  @override
  _ColumnResizingScreenState createState() => _ColumnResizingScreenState();
}

class _ColumnResizingScreenState extends State<ColumnResizingScreen> {
  final List<PlutoColumn> columns = [];

  final List<PlutoRow> rows = [];

  late final PlutoGridStateManager stateManager;

  void setColumnSizeConfig(PlutoGridColumnSizeConfig config) {
    stateManager.setColumnSizeConfig(config);
  }

  @override
  void initState() {
    super.initState();

    final dummyData = DummyData(10, 30);

    columns.addAll(dummyData.columns);

    rows.addAll(dummyData.rows);
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Column resizing',
      topTitle: 'Column resizing',
      topContents: const [
        Text(
          'You can resize the column by dragging the icon to the right of the column.',
        ),
        Text(
          'In autoSize mode, you must select Resize.pushAndPull mode to maintain the overall size when adjusting the column width.',
        ),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/demo/lib/screen/feature/column_resizing_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onLoaded: (PlutoGridOnLoadedEvent event) {
          stateManager = event.stateManager;
        },
        createHeader: (stateManager) => _Header(
          setConfig: setColumnSizeConfig,
        ),
        configuration: const PlutoGridConfiguration(
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.none,
            resizeMode: PlutoResizeMode.normal,
          ),
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({
    required this.setConfig,
    Key? key,
  }) : super(key: key);

  final void Function(PlutoGridColumnSizeConfig) setConfig;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  PlutoGridColumnSizeConfig columnSizeConfig =
      const PlutoGridColumnSizeConfig();

  final Map<_RestoreAutoSizeOptions, bool> restoreOptions = {};

  @override
  void initState() {
    super.initState();

    restoreOptions[_RestoreAutoSizeOptions.restoreAutoSizeAfterHideColumn] =
        columnSizeConfig.restoreAutoSizeAfterHideColumn;
    restoreOptions[_RestoreAutoSizeOptions.restoreAutoSizeAfterFrozenColumn] =
        columnSizeConfig.restoreAutoSizeAfterFrozenColumn;
    restoreOptions[_RestoreAutoSizeOptions.restoreAutoSizeAfterMoveColumn] =
        columnSizeConfig.restoreAutoSizeAfterMoveColumn;
    restoreOptions[_RestoreAutoSizeOptions.restoreAutoSizeAfterInsertColumn] =
        columnSizeConfig.restoreAutoSizeAfterInsertColumn;
    restoreOptions[_RestoreAutoSizeOptions.restoreAutoSizeAfterRemoveColumn] =
        columnSizeConfig.restoreAutoSizeAfterRemoveColumn;
  }

  void _setAutoSize(PlutoAutoSizeMode mode) {
    setState(() {
      columnSizeConfig = columnSizeConfig.copyWith(
        autoSizeMode: mode,
      );
      widget.setConfig(columnSizeConfig);
    });
  }

  void _setResizeMode(PlutoResizeMode mode) {
    setState(() {
      columnSizeConfig = columnSizeConfig.copyWith(
        resizeMode: mode,
      );
      widget.setConfig(columnSizeConfig);
    });
  }

  void _setRestoreOptions(_RestoreAutoSizeOptions option, bool? flag) {
    setState(() {
      restoreOptions[option] = flag == true;

      columnSizeConfig = columnSizeConfig.copyWith(
        restoreAutoSizeAfterHideColumn: restoreOptions[
            _RestoreAutoSizeOptions.restoreAutoSizeAfterHideColumn],
        restoreAutoSizeAfterFrozenColumn: restoreOptions[
            _RestoreAutoSizeOptions.restoreAutoSizeAfterFrozenColumn],
        restoreAutoSizeAfterMoveColumn: restoreOptions[
            _RestoreAutoSizeOptions.restoreAutoSizeAfterMoveColumn],
        restoreAutoSizeAfterInsertColumn: restoreOptions[
            _RestoreAutoSizeOptions.restoreAutoSizeAfterInsertColumn],
        restoreAutoSizeAfterRemoveColumn: restoreOptions[
            _RestoreAutoSizeOptions.restoreAutoSizeAfterRemoveColumn],
      );

      widget.setConfig(columnSizeConfig);
    });
  }

  void _handleAutoSizeNone() {
    _setAutoSize(PlutoAutoSizeMode.none);
  }

  void _handleAutoSizeEqual() {
    _setAutoSize(PlutoAutoSizeMode.equal);
  }

  void _handleAutoSizeScale() {
    _setAutoSize(PlutoAutoSizeMode.scale);
  }

  void _handleResizeNone() {
    _setResizeMode(PlutoResizeMode.none);
  }

  void _handleResizeNormal() {
    _setResizeMode(PlutoResizeMode.normal);
  }

  void _handleResizePushAndPull() {
    _setResizeMode(PlutoResizeMode.pushAndPull);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: columnSizeConfig.autoSizeMode.isNone
                    ? Colors.blue
                    : Colors.grey,
              ),
              onPressed: _handleAutoSizeNone,
              child: const Text('AutoSize none'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: columnSizeConfig.autoSizeMode.isEqual
                    ? Colors.blue
                    : Colors.grey,
              ),
              onPressed: _handleAutoSizeEqual,
              child: const Text('AutoSize equal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: columnSizeConfig.autoSizeMode.isScale
                    ? Colors.blue
                    : Colors.grey,
              ),
              onPressed: _handleAutoSizeScale,
              child: const Text('AutoSize scale'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: columnSizeConfig.resizeMode.isNone
                    ? Colors.blue
                    : Colors.grey,
              ),
              onPressed: _handleResizeNone,
              child: const Text('Resize none'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: columnSizeConfig.resizeMode.isNormal
                    ? Colors.blue
                    : Colors.grey,
              ),
              onPressed: _handleResizeNormal,
              child: const Text('Resize normal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: columnSizeConfig.resizeMode.isPushAndPull
                    ? Colors.blue
                    : Colors.grey,
              ),
              onPressed: _handleResizePushAndPull,
              child: const Text('Resize pushAndPull'),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton(
                hint: const Text('restoreAutoSizeOptions'),
                onChanged: (_RestoreAutoSizeOptions? option) {},
                items: _RestoreAutoSizeOptions.values
                    .map<DropdownMenuItem<_RestoreAutoSizeOptions>>(
                        (_RestoreAutoSizeOptions option) {
                  return DropdownMenuItem<_RestoreAutoSizeOptions>(
                    value: option,
                    onTap: () {
                      _setRestoreOptions(option, !restoreOptions[option]!);
                    },
                    child: Row(
                      children: [
                        StatefulBuilder(builder: (_, setter) {
                          return PlutoScaledCheckbox(
                            value: restoreOptions[option],
                            handleOnChanged: (flag) {
                              setter(() {
                                _setRestoreOptions(option, flag);
                              });
                            },
                          );
                        }),
                        Text(option.name),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _RestoreAutoSizeOptions {
  restoreAutoSizeAfterHideColumn,
  restoreAutoSizeAfterFrozenColumn,
  restoreAutoSizeAfterMoveColumn,
  restoreAutoSizeAfterInsertColumn,
  restoreAutoSizeAfterRemoveColumn,
}
