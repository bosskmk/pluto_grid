import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../dummy_data/development.dart';
import '../../widget/pluto_example_button.dart';
import '../../widget/pluto_example_screen.dart';

class GridAsPopupScreen extends StatefulWidget {
  static const routeName = 'feature/grid-as-popup';

  const GridAsPopupScreen({Key? key}) : super(key: key);

  @override
  _GridAsPopupScreenState createState() => _GridAsPopupScreenState();
}

class _GridAsPopupScreenState extends State<GridAsPopupScreen> {
  TextEditingController? _nameController;

  TextEditingController? _moneyController;

  List<PlutoColumn>? columns;

  List<PlutoRow>? rows;

  @override
  void dispose() {
    _nameController!.dispose();

    _moneyController!.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();

    _moneyController = TextEditingController();

    columns = [
      PlutoColumn(
        title: 'name',
        field: 'name',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'money',
        field: 'money',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'registered at',
        field: 'registered_at',
        type: PlutoColumnType.date(),
      ),
    ];

    rows = DummyData.rowsByColumns(length: 30, columns: columns);
  }

  void openGridPopup(BuildContext context, String selectFieldName) {
    final controller =
        selectFieldName == 'name' ? _nameController : _moneyController;

    PlutoGridPopup(
      context: context,
      columns: columns,
      width: 600,
      rows: rows,
      mode: PlutoGridMode.select,
      onLoaded: (PlutoGridOnLoadedEvent event) {
        rows!.asMap().entries.forEach((element) {
          final cell = element.value.cells[selectFieldName]!;

          if (cell.value.toString() == controller!.text) {
            event.stateManager!.setCurrentCell(cell, element.key);
            event.stateManager!
                .moveScrollByRow(PlutoMoveDirection.up, element.key + 1);
          }
        });

        event.stateManager!.setShowColumnFilter(true);
      },
      onSelected: (PlutoGridOnSelectedEvent event) {
        controller!.text = event.row!.cells[selectFieldName]!.value.toString();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlutoExampleScreen(
      title: 'Grid as Popup',
      topTitle: 'Grid as Popup',
      topContents: const [
        Text(
            'You can call the popup with the desired data and select a value from the called list.'),
        Text(
            'Click the magnifying glass icon on the right side of the TextField to call the popup.'),
        Text(
            'And when you tap one of the list in the pop-up or press Enter key, the item is selected and the value is automatically entered.'),
      ],
      topButtons: [
        PlutoExampleButton(
          url:
              'https://github.com/bosskmk/pluto_grid/blob/master/example/lib/screen/feature/grid_as_popup_screen.dart',
        ),
      ],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Select name',
              hintText: 'Select name',
              suffixIcon: InkWell(
                onTap: () => openGridPopup(context, 'name'),
                child: const Icon(Icons.search),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          TextField(
            controller: _moneyController,
            decoration: InputDecoration(
              labelText: 'Select money',
              hintText: 'Select money',
              suffixIcon: InkWell(
                onTap: () => openGridPopup(context, 'money'),
                child: const Icon(Icons.search),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
