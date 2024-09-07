import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/sprite.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '/Game/ui_control.dart';
import '/db.dart';
import 'events/event_manager.dart';
import 'input.dart';

import 'user_data/user_data.dart';
import 'player.dart';
import 'map.dart';

// ignore: unused_import
import '../my_logger.dart';

class MyGame extends FlameGame {
  PackageInfo packageInfo;

  MemoryDB memoryDB;
  UserDataManager userData;
  MyGame(
      {required this.packageInfo,
      required this.memoryDB,
      required this.userData});

  late SpriteSheet trapSheet;

  // initで初期化するもの(reset対応)
  late int currentStage;
  late EventManager event;
  late Input input;

  late MovePlayerComponent player;
  late TiledMap map;

  late UIControl uiControl;

  GameWidget createWidget() {
    return GameWidget(key: const GlobalObjectKey("game"), game: this);
  }

  static Future<MyGame> create() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 表示用データ読み込み
    await PlayerComponent.load();
    await TiledMap.load();

    // パッケージ情報
    var packageInfo = await PackageInfo.fromPlatform();
    // DBロード
    var memoryDB = await MemoryDB.create();
    var storageDB = await StorageDB.create(packageInfo);

    // ユーザーデータの作成
    var userData =
        await UserDataManager.create(memoryDB, storageDB, withDBDrop: true);

    var self = MyGame(
        packageInfo: packageInfo, memoryDB: memoryDB, userData: userData);

    // 罠(仮) 後でTiledに入れるかも
    var trapImg = await self.images.load("tdrpg_interior.png");
    self.trapSheet = SpriteSheet(image: trapImg, srcSize: Vector2.all(32));

    // 全体の初期化
    self.init(0);
    self.event.add(self.event.createFromDB("on_start"));

    return self;
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
