import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';

// import '../logger.dart';
import '../UI_Widgets/message_window.dart';
import 'player.dart';
import 'map.dart';

class MyGame extends FlameGame with TapCallbacks {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    // log.d("onLoad");

    // 画面構築
    add(await PlayerComponent.create());
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

  // @override
  // void update(double dt) {
  //   super.update(dt);
  // }

  GameWidget getWidget() {
    return GameWidget(game: this);
  }
}
