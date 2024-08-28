import '../my_game.dart';

import 'level_msg.dart';
import 'level_events/level0.dart';

// ignore: unused_import
import '../../my_logger.dart';

class EventNext {
  String? type;
  String? name;
  EventNext(this.type, this.name);

  @override
  String toString() {
    return "$type:$name";
  }
}

abstract class EventElement {
  static late MyGame _myGame;

  MyGame myGame;
  String name;
  EventNext next = EventNext(null, null);
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
    log.info("finish $runtimeType:$name => $next");

    // nextがあれば次のイベントを登録
    if (next.type != null && next.name != null) {
      myGame.eventManager.add(next.type!, next.name!);
    }
  }
}

class EventManager {
  late MyGame myGame;
  int currentLevel;
  final List<EventElement> _eventList = [];

  bool get isEmpty => _eventList.isEmpty;
  bool get isNotEmpty => _eventList.isNotEmpty;

  EventManager(this.myGame, this.currentLevel) {
    EventElement._myGame = myGame;
  }

  // イベントを登録
  void addElement(EventElement event) {
    _eventList.add(event);
  }

  void add(String type, String name) {
    EventElement? element = switch (type) {
      "msg" => EventMessage.fromDB(name),
      "action" => getEventLv0(type, name),
      _ => null,
    };

    // 見知らぬイベントタイプ
    if (element == null) {
      log.info("event not found: $type, $name");
      return;
    }

    addElement(element);
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

  void onMsgTap() {
    for (var event in _eventList) {
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
