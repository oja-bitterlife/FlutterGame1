import '../my_game.dart';

import 'event_element.dart';
import 'level_msg.dart';

// ignore: unused_import
import '../../my_logger.dart';

import 'level_events/level0.dart';

class EventManager {
  late MyGame myGame;
  int currentLevel;
  final List<EventElement> eventList = [];

  bool get isEmpty => eventList.isEmpty;
  bool get isNotEmpty => eventList.isNotEmpty;

  EventManager(this.myGame, this.currentLevel);

  // イベントを登録
  void addElement(EventElement event) {
    eventList.add(event);
  }

  void add(String type, String name) {
    EventElement element = switch (type) {
      "msg" => EventMessage.fromDB(myGame, name),
      "action" => getEventLv0(myGame, type, name),
      _ => EventElement.empty(myGame),
    };

    // 見知らぬイベントタイプ
    if (element.isEmpty) {
      log.info("event not found: $type:$name");
      return;
    }

    addElement(element);
  }

  void update() {
    for (var event in eventList) {
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

  void onMsgTap() {
    for (var event in eventList) {
      if (event is EventMessage) {
        event.nextPage();
      }
    }
  }

  // 移動終了時イベント
  void onMoveFinish(int blockX, int blockY) {
    // move.onMoveFinish(blockX, blockY);
  }
}
