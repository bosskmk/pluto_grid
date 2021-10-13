import 'package:pluto_grid/pluto_grid.dart';

abstract class IOptimisationState {
  /// Flag for optimising the row height.
  bool? get optimiseRowHeight;
}

mixin OptimisationState implements IPlutoGridState {
  bool? get optimiseRowHeight => _optimiseRowHeight;

  bool _optimiseRowHeight = true;

  void setOptimiseRowHeight(
    bool flag, {
    bool notify = true,
  }) {
    _optimiseRowHeight = flag;

    if (notify) {
      notifyListeners();
    }
  }
}
