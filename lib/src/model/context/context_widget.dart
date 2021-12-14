import 'context_model.dart';

mixin ContextWidget<Model extends ContextModel<Widget>, Widget> {
  Model get model;

  void updateContext() {
    model.updateContext(this as Widget);
  }
}
