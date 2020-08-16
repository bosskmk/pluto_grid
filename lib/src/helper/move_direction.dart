part of pluto_grid;

enum MoveDirection {
  Left,
  Right,
  Up,
  Down,
}

extension MoveDirectionExtension on MoveDirection {
  bool get horizontal {
    switch (this) {
      case MoveDirection.Left:
      case MoveDirection.Right:
        return true;
      default:
        return false;
    }
  }

  bool get vertical {
    switch (this) {
      case MoveDirection.Up:
      case MoveDirection.Down:
        return true;
      default:
        return false;
    }
  }

  int get offset {
    switch (this) {
      case MoveDirection.Left:
      case MoveDirection.Up:
        return -1;
      case MoveDirection.Right:
      case MoveDirection.Down:
        return 1;
      default:
        return 0;
    }
  }

  bool get isLeft {
    return MoveDirection.Left == this;
  }

  bool get isRight {
    return MoveDirection.Right == this;
  }

  bool get isUp {
    return MoveDirection.Up == this;
  }

  bool get isDown {
    return MoveDirection.Down == this;
  }
}
