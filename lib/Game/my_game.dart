import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/sprite.dart';

import '../UI_Widgets/player_cursor.dart';
import '../UI_Widgets/message_window.dart';
import 'game_db.dart';
import 'player.dart';
import 'map.dart';
import 'events/event_manager.dart';

// ignore: unused_import
import '../my_logger.dart';

class MyGame extends FlameGame with TapCallbacks, KeyboardEvents {
  late GameDB db;

  late MovePlayerComponent player;
  late TiledMap map;
  late EventManager eventManager;

  late SpriteSheet trapSheet;

  @override
  Future<void> onLoad() async {
    // DBを開いておく
    await GameDB.init(this);

    var eventDB = await openEventDB("assets/data/data.sqlite");
    var result = eventDB.select("select * from message_event");
    result.forEach(log.info);

    // var userDB = await openUserDB();
    // var result = userDB.select("select * from user");
    // result.forEach(log.info);

    // 画像読み込み
    await PlayerComponent.load();
    await TiledMap.load(this);

    // DBの作成
    db = GameDB(this, TiledMap.getEventTiles(), TiledMap.getMoveTiles());

    // 全体の初期化
    await init();
  }

  GameWidget createWidget() {
    return GameWidget(key: const GlobalObjectKey("game"), game: this);
  }

  // スタート時のみ初期化(onLoadの後)
  @override
  void onMount() {
    super.onMount();

    // アクションから開始
    eventManager.startAction("on_start");
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
    map = TiledMap(this);

    // event管理
    eventManager = await EventManager.create(this);

    // UIリセット
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.hide();

    // 罠
    var trapImg = await images.load("tdrpg_interior.png");
    trapSheet = SpriteSheet(image: trapImg, srcSize: Vector2.all(32));
  }

  // 入力受付
  void startIdle() {
    if (eventManager.update()) {
      return;
    }

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
  Future<void> restart(bool withStartAction) async {
    removeAll(children); // 一旦全部消す
    await init();

    if (withStartAction) {
      // 基本はアクションから開始
      eventManager.startAction("on_start");
    } else {
      startIdle();
    }
  }
}
