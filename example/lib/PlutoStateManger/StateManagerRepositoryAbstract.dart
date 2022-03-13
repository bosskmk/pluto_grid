abstract class StateManagerRepositoryAbstract {
  late String prefsKey;

  Map<String, dynamic>? getData(String key);

  Future<bool?> setData(String key, Map<String, dynamic> data);
}
