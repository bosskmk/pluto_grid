import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class ValueFormatterScreen extends StatefulWidget {
  static const routeName = 'feature/value-formatter';

  @override
  _ValueFormatterScreenState createState() => _ValueFormatterScreenState();
}

class _ValueFormatterScreenState extends State<ValueFormatterScreen> {
  List<PlutoColumn> columns;

  List<PlutoRow> rows;

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(
        title: 'Permission',
        field: 'permission',
        type: PlutoColumnType.number(),
        formatter: (String value) {
          if (value == '1') {
            return '(1) Allowed';
          } else {
            return '(0) Disallowed';
          }
        },
      ),
      PlutoColumn(
        title: 'Permission readonly',
        field: 'permission_readonly',
        type: PlutoColumnType.number(
          readOnly: true,
        ),
        applyFormatterInEditing: true,
        formatter: (String value) {
          if (value == '1') {
            return '(1) Allowed';
          } else {
            return '(0) Disallowed';
          }
        },
      ),
      PlutoColumn(
        title: 'Group',
        field: 'group',
        type: PlutoColumnType.select(['A', 'B', 'C', 'N']),
        applyFormatterInEditing: true,
        formatter: (String value) {
          switch (value) {
            case 'A':
              return '(A) Admin';
            case 'B':
              return '(B) Manager';
            case 'C':
              return '(C) User';
          }

          return '(N) None';
        },
      ),
      PlutoColumn(
        title: 'Group original value',
        field: 'group_original_value',
        type: PlutoColumnType.select(['A', 'B', 'C', 'N']),
        applyFormatterInEditing: false,
        formatter: (String value) {
          switch (value) {
            case 'A':
              return '(A) Admin';
            case 'B':
              return '(B) Manager';
            case 'C':
              return '(C) User';
          }

          return '(N) None';
        },
      ),
    ];

    rows = [
      PlutoRow(
        cells: {
          'permission': PlutoCell(value: 0),
          'permission_readonly': PlutoCell(value: 0),
          'group': PlutoCell(value: 'A'),
          'group_original_value': PlutoCell(value: 'A'),
        },
      ),
      PlutoRow(
        cells: {
          'permission': PlutoCell(value: 1),
          'permission_readonly': PlutoCell(value: 1),
          'group': PlutoCell(value: 'B'),
          'group_original_value': PlutoCell(value: 'B'),
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Value formatter',
      topTitle: 'Value formatter',
      topContents: [
        Text('Formatter for display of cell values.'),
        Text(
            'You can output the desired value, not the actual value, in the view state, not the edit state.'),
        Text(
            'In the case of a readonly or popup type column where text cannot be directly edited, if applyFormatterInEditing is set to true, the formatter is applied even in the editing state.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/value_formatter_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoOnChangedEvent event) {
          print(event);
        },
      ),
    );
  }
}
