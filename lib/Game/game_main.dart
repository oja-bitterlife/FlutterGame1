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
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");

    // メッセージウインドウ表示中でなく、移動中でもない
    if (!msgWin.currentState!.isVisible && !player.isMoving()) {
      // キーボードで動かせる
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        player.setMove(PlayerDir.left);
        return KeyEventResult.handled;
      }
      if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        player.setMove(PlayerDir.right);
        return KeyEventResult.handled;
      }
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
        player.setMove(PlayerDir.up);
        return KeyEventResult.handled;
      }
      if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
        player.setMove(PlayerDir.down);
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  // @override
  // void update(double dt) {
  //   super.update(dt);
  // }

  GameWidget getWidget() {
    return GameWidget(game: this);
  }
}
