import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/events.dart';
import '../logger.dart';

import '../UI_Widgets/message_window.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame/Sprite.dart';
import 'package:flame/components.dart';

class MyGame extends FlameGame with TapCallbacks {
  late TiledMap map;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    log.d("onLoad");

    final playerSheet = SpriteSheet.fromColumnsAndRows(
        image: await images.load('sample20160312.png'), columns: 18, rows: 12);

    final TiledComponent tiledMap =
        await TiledComponent.load("map.tmx", Vector2(32.0, 32.0));
    await add(tiledMap);

    final player = SpriteAnimationComponent(
      animation: SpriteAnimation.fromFrameData(
          playerSheet.image,
          SpriteAnimationData([
            playerSheet.createFrameData(8, 6, stepTime: 0.5),
            playerSheet.createFrameData(8, 7, stepTime: 0.5),
            playerSheet.createFrameData(8, 8, stepTime: 0.5),
            playerSheet.createFrameData(8, 7, stepTime: 0.5),
          ])),
      anchor: Anchor.bottomCenter,
      size: Vector2(48, 64),
    );
    await add(player);
    player.position = Vector2(64, 448);

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
