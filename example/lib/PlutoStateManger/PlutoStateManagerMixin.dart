import 'package:pluto_grid/pluto_grid.dart';

import 'StateManagerRepository.dart';

mixin PlutoStateManagerMixin {
  late final PlutoGridStateManager _stateManager;
  late final StateManagerRepository _managerRepository;

  void initStateManger(PlutoGridOnLoadedEvent event, String prefsKey) async {
    await _initStateManagerRepository(event.stateManager, prefsKey);

    _initColumnsState();
    _listenToStateManger();
  }

  Future _initStateManagerRepository(stateManager, prefsKey) async {
    _stateManager = stateManager;
    _managerRepository = StateManagerRepository(prefsKey);
    await _managerRepository.init();
  }

  void _listenToStateManger() {
    _stateManager.addListener(() {
      final fields = _stateManager.refColumns.map((e) => e.field).toList();
      _managerRepository.setColumnsState({'lastOrder': fields});
    });
  }

  void _initColumnsState() {
    final columnState = _managerRepository.getColumnsState();
    if (columnState != null && columnState.isNotEmpty) {
      final List<dynamic>? lastOrderState = (columnState['lastOrder'] as List?);

      if (lastOrderState != null && lastOrderState.isNotEmpty) {
        final List<String> lastOrder =
            lastOrderState.map((e) => e as String).toList();
        final refColumns = _stateManager.refColumns.toList();
        _stateManager.refColumns.clear();

        reOrderWithNotify(refColumns, lastOrder);
      }
    }
  }

  // refColumns with new instance
  // newColumnsFields example: ['id','name','email']
  void reOrderWithNotify(
      List<PlutoColumn> refColumns, List<String> newColumnsFields) {
    for (var columnField in newColumnsFields) {
      final refColumn = refColumns.firstWhere((n) => n.field == columnField);
      _stateManager.refColumns.add(refColumn);
    }

    _stateManager.notifyListeners();
  }
}
