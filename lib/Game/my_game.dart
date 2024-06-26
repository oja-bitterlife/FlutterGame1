import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

// ignore: unused_import
import '../my_logger.dart';
import 'player.dart';
import 'map.dart';

class MyGame extends FlameGame with TapCallbacks, KeyboardEvents {
  late MovePlayerComponent player;
  late TiledManager map;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 画像読み込み
    await PlayerComponent.load();
    add(player = MovePlayerComponent());

    // 画面構築
    map = await TiledManager.create(this);
  }

  GameWidget createWidget() {
    return GameWidget(key: const GlobalObjectKey("game"), game: this);
  }

  // スタート時初期化
  @override
  void onMount() {
    super.onMount();

    // 待機状態で開始
    player.startIdle();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    // ゲーム画面のタップ処理。たぶん今回は使わない
    log.info("onGameTap");
  }
}
