import 'package:pluto_grid/pluto_grid.dart';

import 'context_model.dart';

mixin ContextWidget<Model extends ContextModel<Widget>,
    Widget extends HasPlutoStateManager<PlutoGridStateManager>> {
  Model get model;

  void updateContext() {
    model.updateContext(this as Widget);
  }
}
