import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class TextTypeColumnScreen extends StatefulWidget {
  static const routeName = 'feature/text-type-column';

  const TextTypeColumnScreen({Key? key}) : super(key: key);

  @override
  _TextTypeColumnScreenState createState() => _TextTypeColumnScreenState();
}

class _TextTypeColumnScreenState extends State<TextTypeColumnScreen> {
  List<PlutoColumn>? columns;

  List<PlutoRow>? rows;

  @override
  void initState() {
    super.initState();

    columns = [
      PlutoColumn(
        title: 'Editable',
        field: 'editable',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Readonly',
        field: 'readonly',
        readOnly: true,
        type: PlutoColumnType.text(),
      ),
    ];

    rows = [
      PlutoRow(
        cells: {
          'editable': PlutoCell(value: 'a1'),
          'readonly': PlutoCell(value: 'b1'),
        },
      ),
      PlutoRow(
        cells: {
          'editable': PlutoCell(value: 'a1'),
          'readonly': PlutoCell(value: 'b1'),
        },
      ),
      PlutoRow(
        cells: {
          'editable': PlutoCell(value: 'a1'),
          'readonly': PlutoCell(value: 'b1'),
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Text type column',
      topTitle: 'Text type column',
      topContents: const [
        Text('A column to enter a character value.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/text_type_column_screen.dart',
        ),
      ],
      body: PlutoGrid(
        columns: columns,
        rows: rows,
        onChanged: (PlutoGridOnChangedEvent event) {
          print(event);
        },
      ),
    );
  }
}
