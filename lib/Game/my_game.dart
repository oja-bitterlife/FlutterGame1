import 'package:flame/cache.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/sprite.dart';

// ignore: unused_import
import '../my_logger.dart';
import '../UI_Widgets/player_cursor.dart';
import '../UI_Widgets/message_window.dart';
import 'game_db.dart';
import 'player.dart';
import 'map.dart';
import 'events/event_manager.dart';
import 'actions/level_action.dart';

class MyGame extends FlameGame with TapCallbacks, KeyboardEvents {
  late GameDB db;

  late MovePlayerComponent player;
  late TiledManager map;
  late EventManager eventManager;
  late Level1Action levelAction;

  late SpriteSheet trapSheet;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // DBを開いておく
    db = await GameDB.init();

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
    eventManager = await EventManager.create(this);

    // UIリセット
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.hide();

    // 罠
    var trapImg = await images.load("tdrpg_interior.png");
    trapSheet = SpriteSheet(image: trapImg, srcSize: Vector2.all(32));

    // アクション開始から
    levelAction = Level1Action(this);
    levelAction.startAction("onStart");
  }

  // 入力受付
  void startIdle() {
    if (levelAction.isPlaying) {
      levelAction.playAction();
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
  Future<void> restart() async {
    removeAll(children); // 一旦全部消す
    init();
    startIdle(); // onmount後で必要(init内ではダメ)
  }
}
