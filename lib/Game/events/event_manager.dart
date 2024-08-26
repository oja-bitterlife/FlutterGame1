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

  late LevelMessageBase message;
  late LevelActionBase action;
  late LevelIdleBase move;

  EventManager(this.myGame);

  static Future<EventManager> create(MyGame myGame) async {
    var self = EventManager(myGame);

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

  // マップ上にイベントが存在するか調べる
  String? getMapEvent(int blockX, int blockY) {
    // 上書きイベントを確認
    var eventName = myGame.userData.getMapEvent(blockX, blockY);
    if (eventName != null) return eventName; // イベント名を返す

    // マップのイベントを確認
    int gid = myGame.map.getEventGid(blockX, blockY);
    if (gid != 0) {
      return myGame.map.getTilesetProperty(gid, "event");
    }

    // イベントは特になかった
    return null;
  }

  // Findアイコンが押された(イベントオブジェクトがある)
  void onFind(int blockX, int blockY) {
    String? type = getMapEvent(blockX, blockY);
    if (type != null) {
      message.onFind(type, blockX, blockY);
    }
  }

  void startMessage(String type, int blockX, int blockY, {List<String>? data}) {
    action.reset(); // アクションを止める
    if (data != null) {
      message.startString(type, blockX, blockY, data);
    } else {
      message.startEvent(type, blockX, blockY);
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
  void onMessageFinish(
      String type, int blockX, int blockY, String? changeNext) {
    message.onMessageFinish(type, blockX, blockY, changeNext);
  }

  // アクション終わりコールバック
  void onActionFinish(String type) {
    action.onActionFinish(type);
  }
}
