import 'dart:async';

class PlutoDebounceByHashCode {
  Timer? _debounce;

  int? _previousHashCode;

  void dispose() {
    _debounce?.cancel();
  }

  bool isDebounced({
    required int hashCode,
    bool ignore = false,
    Duration duration = const Duration(milliseconds: 1),
  }) {
    if (ignore) {
      return false;
    }

    if (_previousHashCode == hashCode) {
      return true;
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(duration, () {
      _previousHashCode = null;
    });

    _previousHashCode = hashCode;

    return false;
  }
}
