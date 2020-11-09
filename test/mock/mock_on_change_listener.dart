import 'package:mockito/mockito.dart';

class OnchangeListenerTest {
  void onChangeVoidNoParamListener() {}
}

class MockOnChangeListener extends Mock implements OnchangeListenerTest {}