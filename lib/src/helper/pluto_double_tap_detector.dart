import 'package:pluto_grid_plus/pluto_grid_plus.dart';

class PlutoDoubleTapDetector {
  static PlutoCell? _prevTappedCell;
  static int _lastTap = DateTime.now().millisecondsSinceEpoch;
  static int _consecutiveTaps = 1;

  static bool isDoubleTap(PlutoCell cell) {
    int now = DateTime.now().millisecondsSinceEpoch;
    bool doubleTap = false;
    if (now - _lastTap < 300) {
      _consecutiveTaps++;
      if (_consecutiveTaps >= 2 && _prevTappedCell == cell) {
        doubleTap = true;
      }
    } else {
      _consecutiveTaps = 1;
      doubleTap = false;
    }
    _lastTap = now;
    _prevTappedCell = cell;
    return doubleTap;
  }
}
