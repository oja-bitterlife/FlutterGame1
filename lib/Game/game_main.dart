import 'package:flame/game.dart';
import 'package:flame/events.dart';

import '../logger.dart';
import 'player.dart';
import 'map.dart';

class MyGame extends FlameGame with TapCallbacks, KeyboardEvents {
  late PlayerMoveComponent player;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 画像読み込み
    await PlayerComponent.load();

    // 画面構築
    player = PlayerMoveComponent();
    add(player);
    add(await MapComponent.create());
  }

  GameWidget getWidget() {
    return GameWidget(game: this);
  }
}
