import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../logger.dart';
import 'player.dart';
import 'map.dart';

class MyGame extends FlameGame with TapCallbacks, KeyboardEvents {
  late MovePlayerComponent player;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 画像読み込み
    await PlayerComponent.load();

    // 画面構築
    player = MovePlayerComponent();
    add(player);
    add(await MapComponent.create());
  }

  GameWidget createWidget() {
    return GameWidget(key: const GlobalObjectKey("game"), game: this);
  }

  // スタート時初期化
  @override
  void onMount() {
    super.onMount();

    // 移動が終わった状態から開始
    player.moveFinishCallback();
  }
}
