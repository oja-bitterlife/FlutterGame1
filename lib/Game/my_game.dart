import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/sprite.dart';
import 'package:my_app/Game/ui_control.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  late UserDataManager userData;

  int currentStage = 0;
  late EventManager event;
  late Input input;

  late MovePlayerComponent player;
  late TiledMap map;
  late SpriteSheet trapSheet;

  late UIControl uiControl;

  GameWidget createWidget() {
    return GameWidget(key: const GlobalObjectKey("game"), game: this);
  }

  static Future<MyGame> create() async {
    var self = MyGame();
    return self;
  }

  @override
  Future<void> onLoad() async {
    // DBロード
    memoryDB = await MemoryDB.create();

    // データ読み込み
    await PlayerComponent.load();
    await TiledMap.load(this);
    // 罠(仮) 後でTiledに入れるかも
    var trapImg = await images.load("tdrpg_interior.png");
    trapSheet = SpriteSheet(image: trapImg, srcSize: Vector2.all(32));

    // ユーザーデータの作成
    userData = await UserDataManager.init(this, withDBDrop: true);

    // 全体の初期化
    init(0);
    event.add(event.createFromDB("on_start"));
  }

  // 画面構築(Components)
  void init(int stageNo) {
    currentStage = stageNo;

    // デバッグ用
    checkDBEvents(memoryDB.db, currentStage);

    // 入力管理
    add(input = Input(512, 512));

    // プレイヤ表示
    add(player = MovePlayerComponent(7, 14));

    // マップ表示
    map = TiledMap(this);

    // UI操作
    uiControl = UIControl();

    // イベント管理
    add(event = EventManager(this));
  }

  // 状態のリセット
  void reset(int stageNo) {
    removeAll(children); // 一旦全部消す

    // レベル指定で再構築
    init(stageNo); // 再構築
  }

  // 状態の更新
  @override
  void update(double dt) {
    super.update(dt);
    uiControl.update();
  }
}
