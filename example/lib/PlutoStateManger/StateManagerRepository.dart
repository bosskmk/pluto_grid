import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'StateManagerRepositoryAbstract.dart';

class StateManagerRepository implements StateManagerRepositoryAbstract {
  static late SharedPreferences prefs;
  static const COLUMNS_STATE = 'columnsState';

  @override
  late String prefsKey;

  StateManagerRepository(this.prefsKey);

  Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Map<String, dynamic>? getData(String key) {
    try {
      final decoded = prefs.getString(prefsKey + key);
      if (decoded != null) {
        return jsonDecode(decoded);
      }
    } catch (e) {
      prefs.remove(prefsKey + key);
    }
  }

  @override
  Future<bool?> setData(String key, Map<String, dynamic> data) async {
    final decoded = jsonEncode(data);

    return prefs.setString(prefsKey + key, decoded);
  }

  Map<String, dynamic>? getColumnsState() {
    return getData(COLUMNS_STATE);
  }

  Future<bool?> setColumnsState(Map<String, dynamic> value) {
    return setData(COLUMNS_STATE, value);
  }
}
