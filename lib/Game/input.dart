import 'package:flame/components.dart';
import 'package:flame/events.dart';

// ignore: unused_import
import '../my_logger.dart';

class Input extends PositionComponent with TapCallbacks {
  bool isPressed = false;
  bool isPrePressed = false;

  bool get isTrgDown => isPressed && !isPrePressed;
  bool get isTrgUp => !isPressed && isPrePressed;

  // EventManagerより遅くする
  Input(int width, int height)
      : super(priority: 1, size: Vector2(width as double, height as double));

  @override
  void update(double dt) {
    isPrePressed = isPressed;
  }

  // 入力更新
  @override
  void onTapDown(TapDownEvent event) {
    log.info("onTap");
    isPressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    isPressed = false;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    // 画面外にでたらリセット
    isPrePressed = isPressed = false;
  }
}
