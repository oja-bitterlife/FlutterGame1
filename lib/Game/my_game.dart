import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

// ignore: unused_import
import '../my_logger.dart';
import '../UI_Widgets/player_cursor.dart';
import 'player.dart';
import 'map.dart';
import 'events/eventManager.dart';

class MyGame extends FlameGame with TapCallbacks, KeyboardEvents {
  late MovePlayerComponent player;
  late TiledManager map;
  late Eventmanager eventManager;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 画像読み込み
    await PlayerComponent.load();

    // 初期化
    await init();
  }

  GameWidget createWidget() {
    return GameWidget(key: const GlobalObjectKey("game"), game: this);
  }

  // スタート時初期化
  @override
  void onMount() {
    super.onMount();

    // 待機状態で開始
    startIdle();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    // ゲーム画面のタップ処理。たぶん今回は使わない
    log.info("onGameTap");
  }

  // 画面構築
  Future<void> init() async {
    add(player = MovePlayerComponent(this));

    // 画面構築
    map = await TiledManager.create(this);
    add(map.underComponent);
    add(map.overComponent);

    // event管理
    eventManager = await Eventmanager.create(this);
  }

  // 入力受付
  void startIdle() {
    const cursor = GlobalObjectKey<PlayerCursorState>("PlayerCursor");

    // プレイヤーの四方向チェック
    int blockX = player.getBlockX();
    int blockY = player.getBlockY();
    cursor.currentState!
      ..setCursorType(checkEvent(blockX - 1, blockY), PlayerDir.left)
      ..setCursorType(checkEvent(blockX + 1, blockY), PlayerDir.right)
      ..setCursorType(checkEvent(blockX, blockY - 1), PlayerDir.up)
      ..setCursorType(checkEvent(blockX, blockY + 1), PlayerDir.down);

    // 操作カーソル表示
    cursor.currentState?.show(player.position);
  }

  PlayerCursorType checkEvent(int blockX, int blockY) {
    switch ((findGame() as MyGame).map.checkEventType(blockX, blockY)) {
      case MapEventType.event:
        return PlayerCursorType.find;
      case MapEventType.wall:
        return PlayerCursorType.none;
      default:
        return PlayerCursorType.move;
    }
  }

  // 最初からやり直す
  Future<void> restart() async {
    removeAll(children); // 一旦全部消す
    init();
    startIdle(); // onmount後で必要(init内ではダメ)
  }
}
