import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/sprite.dart';

import '../UI_Widgets/player_cursor.dart';
import '../UI_Widgets/message_window.dart';
import '../db.dart';
import 'events/event_manager.dart';
import 'input.dart';

import 'events/level_action.dart';
import 'user_data/user_data.dart';
import 'player.dart';
import 'map.dart';

// ignore: unused_import
import '../my_logger.dart';

class MyGame extends FlameGame with TapCallbacks {
  late MemoryDB memoryDB;
  late UserData userData;

  late EventManager eventManager;
  late Input input;

  late MovePlayerComponent player;
  late TiledMap map;
  late SpriteSheet trapSheet;

  GameWidget createWidget() {
    return GameWidget(key: const GlobalObjectKey("game"), game: this);
  }

  @override
  Future<void> onLoad() async {
    // DBロード
    memoryDB = await MemoryDB.create();

    // データ読み込み
    await PlayerComponent.load();
    await TiledMap.load(this);
    // 罠(仮)
    var trapImg = await images.load("tdrpg_interior.png");
    trapSheet = SpriteSheet(image: trapImg, srcSize: Vector2.all(32));

    // ユーザーデータの作成
    userData = await UserData.init(this);

    // 全体の初期化
    init();
  }

  // 画面構築(Components)
  void init() {
    // 入力管理
    add(input = Input());

    // プレイヤ表示
    add(player = MovePlayerComponent(this, 7, 14));

    // マップ表示
    map = TiledMap(this);

    // UIリセット
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.hide();

    // イベント管理
    add(eventManager = EventManager(0));
    eventManager.add(EventActionGroup.fromDB(this, "on_start"));
  }

  // 状態のリセット
  void reset() {
    removeAll(children); // 一旦全部消す
    init(); // 再構築
  }

  @override
  void update(double dt) {
    // 別のことを実行中
    if (eventManager.hasChildren || player.isMoving()) {
      super.update(dt);
      return;
    }

    // 何もなければ操作カーソルを表示する
    const cursor = GlobalObjectKey<PlayerCursorState>("PlayerCursor");
    if (cursor.currentState?.isVisible == false) {
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

    super.update(dt);
  }

  PlayerCursorType checkEvent(int blockX, int blockY) {
    switch (map.checkEventType(blockX, blockY)) {
      case MapEventType.event:
        return PlayerCursorType.find;
      case MapEventType.wall:
        return PlayerCursorType.none;
      default:
        return PlayerCursorType.move;
    }
  }

  // ゲーム画面のタップ処理。たぶん今回は使わない
  @override
  void onTapDown(TapDownEvent event) {
    log.info("onGameTap");
    input.onTapDown();
  }

  @override
  void onTapUp(TapUpEvent event) {
    input.onTapUp();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    input = Input();
  }
}
