import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/sprite.dart';

import '../UI_Widgets/player_cursor.dart';
import '../UI_Widgets/message_window.dart';
import '../db.dart';
import 'events/event_manager.dart';
import 'input.dart';

import 'user_data/user_data.dart';
import 'player.dart';
import 'map.dart';

// ignore: unused_import
import '../my_logger.dart';

class MyGame extends FlameGame {
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
    checkDBEvents(memoryDB.db, 0); // デバッグ用

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
    eventManager.addEvent("on_start");
  }

  // 画面構築(Components)
  void init() {
    // 入力管理
    add(input = Input(512, 512));

    // プレイヤ表示
    add(player = MovePlayerComponent(7, 14));

    // マップ表示
    map = TiledMap(this);

    // UIリセット
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.hide();
    const cursor = GlobalObjectKey<PlayerCursorState>("PlayerCursor");
    cursor.currentState?.hide();

    // イベント管理
    add(eventManager = EventManager(this, 0));
  }

  // 状態のリセット
  void reset() {
    removeAll(children); // 一旦全部消す
    init(); // 再構築
  }

  @override
  void update(double dt) {
    var cursor =
        const GlobalObjectKey<PlayerCursorState>("PlayerCursor").currentState;

    // 別のことを実行中
    if (eventManager.hasChildren || player.isMoving) {
      if (cursor?.isVisible ?? false) cursor!.hide();
      super.update(dt);
      return;
    }

    // 何もなければ操作カーソルを表示する
    if (!(cursor?.isVisible ?? true)) {
      // プレイヤーの四方向チェック
      int blockX = player.getBlockX();
      int blockY = player.getBlockY();
      cursor!
        ..setCursorType(checkBlock(blockX - 1, blockY), PlayerDir.left)
        ..setCursorType(checkBlock(blockX + 1, blockY), PlayerDir.right)
        ..setCursorType(checkBlock(blockX, blockY - 1), PlayerDir.up)
        ..setCursorType(checkBlock(blockX, blockY + 1), PlayerDir.down);

      // 操作カーソル表示
      cursor.show(player.position);
    }

    super.update(dt);
  }

  PlayerCursorType checkBlock(int blockX, int blockY) {
    return switch (map.checkEventType(blockX, blockY)) {
      MapEventType.event => PlayerCursorType.find,
      MapEventType.wall => PlayerCursorType.none,
      _ => PlayerCursorType.move
    };
  }
}
