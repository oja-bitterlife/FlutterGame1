import 'package:flame/game.dart';
import '../logger.dart';

import 'package:flame_tiled/flame_tiled.dart';

class MyGame extends FlameGame {
  late TiledMap map;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    log.d("onLoad");

    // final windowImg = await Sprite.load('window.png');
    // windowImg.image.(Rect.fromLTRB(15, 15, 35, 35))
    // await add(
    //   SpriteComponent(
    //     position: Vector2(size.x * 0.5, size.y * 0.5),
    //     anchor: Anchor.center,
    //     sprite: windowImg,
    //   ),
    // );
    // final img = Image.asset(
    //   "images/window.png",
    //   height: 100,
    //   width: 350,
    //   centerSlice: const Rect.fromLTRB(15, 15, 35, 35),
    // );
    // Sprite(img);

    final TiledComponent tiledMap =
        await TiledComponent.load("map.tmx", Vector2(32.0, 32.0));
    await add(tiledMap);
  }

  GameWidget getWidget() {
    return GameWidget(game: this);
  }
}
