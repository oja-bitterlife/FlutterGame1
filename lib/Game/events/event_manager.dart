import 'package:sqlite3/common.dart';
import '../my_game.dart';
import '../../db.dart';

import 'level_message_base.dart';
import 'level_action_base.dart';
import 'level_idle_base.dart';

import 'level0/level0_message.dart';
import 'level0/level0_action.dart';
import 'level0/level0_idle.dart';

// ignore: unused_import
import '../../my_logger.dart';

class EventManager {
  late MyGame myGame;
  late CommonDatabase eventDB;

  late LevelMessageBase message;
  late LevelActionBase action;
  late LevelIdleBase move;

  EventManager(this.myGame, this.eventDB);

  static Future<EventManager> create(MyGame myGame) async {
    var self = EventManager(myGame, await openEventDB());

    // DBデバッグ
    // var result = self.eventDB
    //     .select("select * from ${LevelMessageBase.messageEventTable}");
    // result.forEach(log.info);

    // とりあえずLevel0を作っていく
    self.message = await Level0Message.create(myGame);
    self.action = await Level0Action.create(myGame);
    self.move = await Level0Idle.create(myGame);

    return self;
  }

  Future<void> reload() async {}

  bool update() {
    action.update();

    // アクション再生中ならtrue
    if (action.isPlaying) return true;

    // メッセージ表示中ならtrue
    if (message.isPlaying) return true;

    return false;
  }

  String? getMapEvent(int blockX, int blockY) {
    var result = myGame.saveLoad.userDB.select(
        "select name from msg_event where player_id = 1 and  x = ? and y = ?",
        [blockX, blockY]);

    // イベントは特にない
    if (result.isEmpty) return null;

    // イベント名を返す
    return result.first["name"];
  }

  // Findアイコンが押された(イベントオブジェクトがある)
  void onFind(int blockX, int blockY) {
    String? type = getMapEvent(blockX, blockY);
    if (type != null) {
      message.onFind(type, blockX, blockY);
    }
  }

  void startMessage(String type, {List<String>? data}) {
    action.reset(); // アクションを止める
    if (data != null) {
      message.startString(type, data);
    } else {
      message.startEvent(type);
    }
  }

  void startAction(String type) {
    action.start(type);
  }

  // Idle開始時イベント
  void onIdle(int blockX, int blockY) {
    move.onIdle(blockX, blockY);
  }

  // メッセージ終わりコールバック
  void onMessageFinish(String type) {
    message.onMessageFinish(type);
  }

  // アクション終わりコールバック
  void onActionFinish(String type) {
    action.onActionFinish(type);
  }
}
