import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import '../logger.dart';

import '../UI_Widgets/message_window.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'player.dart';
import 'Priorities.dart';

class MyGame extends FlameGame with TapCallbacks {
  late TiledMap map;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    log.d("onLoad");

    await add(await PlayerComponent.create(this));

    final TiledComponent tiledMap = await TiledComponent.load(
        "map.tmx", Vector2(32.0, 32.0),
        priority: Priority.map.index);
    await add(tiledMap);

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
