import 'pluto_node.dart';

class PlutoRowNode<T> implements PlutoNode<T> {
  PlutoRowNode({
    required int index,
    required T data,
    PlutoNode? up,
    PlutoNode? down,
  })  : _index = index,
        _data = data,
        _up = up,
        _down = down;

  @override
  int get index => _index;

  set index(int index) => _index = index;

  int _index;

  @override
  T get data => _data;

  set data(T data) => _data = data;

  T _data;

  @override
  PlutoNode? get up => _up;

  set up(PlutoNode? node) => _up = node;

  PlutoNode? _up;

  @override
  PlutoNode? get down => _down;

  set down(PlutoNode? node) => _down = node;

  PlutoNode? _down;

  @override
  PlutoNode? get left => null;

  @override
  PlutoNode? get right => null;
}
