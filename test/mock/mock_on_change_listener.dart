import 'package:mockito/mockito.dart';

class OnchangeListenerTest {
  void onChangeVoidNoParamListener() {}
  void onChangeOneParamListener<T>(T param) {}
}

class MockOnChangeListener extends Mock implements OnchangeListenerTest {}
