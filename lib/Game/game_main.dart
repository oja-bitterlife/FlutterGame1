import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

// import '../logger.dart';
import '../UI_Widgets/message_window.dart';
import 'player.dart';
import 'map.dart';
import '../logger.dart';

class MyGame extends FlameGame with TapCallbacks, KeyboardEvents {
  late PlayerComponent player;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // log.d("onLoad");

    // 画面構築
    player = await PlayerComponent.create();
    add(player);
    add(await MapComponent.create());

    // メッセージ表示お試し
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.show("あいうえお\nかきくけ\nさしす\nたち");
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.hide();
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");

    // メッセージウインドウ表示中は動かさない
    if (msgWin.currentState!.isVisible) {
      return KeyEventResult.ignored;
    }

    // キーボードで動かす
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        player.setDir(PlayerDir.left);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        player.setDir(PlayerDir.right);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        player.setDir(PlayerDir.up);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        player.setDir(PlayerDir.down);
        return KeyEventResult.handled;
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
