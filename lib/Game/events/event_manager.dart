import '../my_game.dart';

import 'level_message_base.dart';
import 'level_action_base.dart';
import 'level_moved_base.dart';

import 'level0/level0_action.dart';
import 'level0/level0_moved.dart';

// ignore: unused_import
import '../../my_logger.dart';

abstract class EventElement {
  static late MyGame _myGame;

  MyGame myGame;
  String name;
  EventElement(this.name) : myGame = _myGame;

  // イベントループ
  void update();

  // 強制終了
  void stop() {
    myGame.eventManager._eventList.remove(this);
  }

  // 通常終了
  void finish() {
    myGame.eventManager._eventList.remove(this);
    onFinish();
  }

  void onFinish() {
    log.info("finish event: $name");
  }
}

class EventManager {
  late MyGame myGame;
  final List<EventElement> _eventList = [];

  bool get isEmpty => _eventList.isEmpty;
  bool get isNotEmpty => _eventList.isNotEmpty;

  EventManager(this.myGame) {
    EventElement._myGame = myGame;
  }

  // イベントを登録
  void add(EventElement event) {
    _eventList.add(event);
  }

  void reset() {
    _eventList.clear();
    _eventList.add(EventOnStart()); // 最初のイベント
  }

  void update() {
    for (var event in _eventList) {
      event.update();
    }
  }

  // マップ上にイベントが存在するか調べる
  String? getMapEvent(int blockX, int blockY) {
    // 上書きイベントを確認
    var eventName = myGame.userData.mapEvent.get(blockX, blockY);
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
      // message.onFind(type, blockX, blockY);
    }
  }

  // 移動終了時イベント
  void onMoveFinish(int blockX, int blockY) {
    // move.onMoveFinish(blockX, blockY);
  }
}
