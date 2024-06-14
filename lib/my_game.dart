import 'package:flame/game.dart';
import 'logger.dart';

// import 'package:flame/components.dart';

import 'package:flame_tiled/flame_tiled.dart';

class MyGame extends FlameGame {
  late TiledMap map;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    log.d("onLoad");

    // final player = await Sprite.load('tdrpg_interior.png');
    // await add(
    //   SpriteComponent(
    //     position: Vector2(size.x * 0.5, size.y * 0.5),
    //     anchor: Anchor.center,
    //     sprite: player,
    //   ),
    // );

    final TiledComponent tiledMap =
        await TiledComponent.load("map.tmx", Vector2(32.0, 32.0));
    await add(tiledMap);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}
