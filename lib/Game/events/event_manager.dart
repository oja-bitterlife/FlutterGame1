import '../my_game.dart';

import 'level_msg.dart';
import 'level_events/level0.dart';

// ignore: unused_import
import '../../my_logger.dart';

abstract class EventElement {
  static late MyGame _myGame;

  MyGame myGame;
  String name;
  String? next;
  EventElement(this.name, [this.next]) : myGame = _myGame;

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
    log.info("finish $runtimeType: $name => $next");

    // nextがあれば次のイベントを登録
    if (next != null) myGame.eventManager.add(next!);
  }
}

class EventManager {
  static const eventTable = "event.event";

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
    log.info("event add: $event");
    _eventList.add(event);
  }

  void add(String name) {
    // DBのイベント情報を確認
    var result = myGame.memoryDB.select(
        "select * from $eventTable where level = ? and name = ?",
        [currentLevel, name]);

    // DBにイベント定義が無かった
    if (result.isEmpty) {
      log.info("event not found: $name");
      return;
    }

    // Lvのイベントを取得して登録
    EventElement? element = switch (result.first["type"]) {
      "msg" => EventMessage.fromDB(name), // msgはここで完結できる
      _ => getEventLv0(result.first["type"], name),
    };
    if (element != null) {
      element.next = result.first["next"];
      addElement(element);
    } else {
      // 対応するLevelEventが無かった
      log.info("level_event not defined: $name");
    }
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
