import 'package:flame/components.dart';

class Input extends Component {
  bool isPressed = false;
  bool isPrePressed = false;

  bool get isTrgDown => isPressed && !isPrePressed;
  bool get isTrgUp => !isPressed && isPrePressed;

  // EventManagerより遅くする
  Input() : super(priority: 1);

  void onTapDown() {
    isPressed = true;
  }

  void onTapUp() {
    isPressed = false;
  }

  @override
  void update(double dt) {
    isPrePressed = isPressed;
  }
}
