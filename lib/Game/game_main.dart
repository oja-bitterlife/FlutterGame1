import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import 'package:flutter/widgets.dart';
import 'package:my_app/UI_Widgets/player_cursor.dart';

import '../logger.dart';
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
  void update(double dt) {
    super.update(dt);

    const cursor = GlobalObjectKey<PlayerCursorState>("PlayerCursor");
    cursor.currentState?.show(player.position);

    // 動ける状態なら動く
    // const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    // if (keyPressed != PlayerDir.hide &&
    //     !msgWin.currentState!.isVisible &&
    //     !player.isMoving()) {
    //   player.setMove(keyPressed);
    // }
  }

  GameWidget getWidget() {
    return GameWidget(game: this);
  }
}
