import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

// import '../logger.dart';
import '../UI_Widgets/message_window.dart';
import 'player.dart';
import 'map.dart';

class MyGame extends FlameGame with TapCallbacks, KeyboardEvents {
  late PlayerMoveComponent player;

  PlayerDir keyPressed = PlayerDir.none;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // log.d("onLoad");
    // 画像読み込み
    await PlayerComponent.load();

    // 画面構築
    player = PlayerMoveComponent();
    add(player);
    add(await MapComponent.create());
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    // 移動中でない
    if (!player.isMoving()) {
      // 調べることができる
      const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
      if (!msgWin.currentState!.isVisible) {
        msgWin.currentState?.show("あいうえお\nかきくけ\nさしす\nたち");
      } else {
        msgWin.currentState?.hide();
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // メッセージウインドウ表示中でなく、移動中でもない
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        keyPressed = PlayerDir.left;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        keyPressed = PlayerDir.right;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        keyPressed = PlayerDir.up;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        keyPressed = PlayerDir.down;
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
          keyPressed == PlayerDir.left) {
        keyPressed = PlayerDir.none;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
          keyPressed == PlayerDir.right) {
        keyPressed = PlayerDir.none;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
          keyPressed == PlayerDir.up) {
        keyPressed = PlayerDir.none;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
          keyPressed == PlayerDir.down) {
        keyPressed = PlayerDir.none;
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 動ける状態なら動く
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    if (keyPressed != PlayerDir.none &&
        !msgWin.currentState!.isVisible &&
        !player.isMoving()) {
      player.setMove(keyPressed);
    }
  }

  GameWidget getWidget() {
    return GameWidget(game: this);
  }
}
