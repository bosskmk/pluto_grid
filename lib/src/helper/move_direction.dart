enum MoveDirection {
  left,
  right,
  up,
  down,
}

extension MoveDirectionExtension on MoveDirection {
  bool get horizontal {
    switch (this) {
      case MoveDirection.left:
      case MoveDirection.right:
        return true;
      default:
        return false;
    }
  }

  bool get vertical {
    switch (this) {
      case MoveDirection.up:
      case MoveDirection.down:
        return true;
      default:
        return false;
    }
  }

  int get offset {
    switch (this) {
      case MoveDirection.left:
      case MoveDirection.up:
        return -1;
      case MoveDirection.right:
      case MoveDirection.down:
        return 1;
      default:
        return 0;
    }
  }

  bool get isLeft {
    return MoveDirection.left == this;
  }

  bool get isRight {
    return MoveDirection.right == this;
  }

  bool get isUp {
    return MoveDirection.up == this;
  }

  bool get isDown {
    return MoveDirection.down == this;
  }
}
