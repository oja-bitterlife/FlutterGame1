import 'dart:async';
import 'package:flame/components.dart';
import 'package:sqlite3/wasm.dart';

import '../my_game.dart';

import 'event_element.dart';
import 'event_data/event_msg.dart';
import 'event_data/event_action.dart';

// ignore: unused_import
import '../../my_logger.dart';

import 'levels/level_base.dart';

// イベント登録用情報
const eventInfo = [
  (table: "msg", data: "text", func: createEventMsg),
  (table: "action", data: "action", func: createEventAction),
];

// EventMangerに付けるイベントツリーのRoot
class EventRoot extends EventElement {
  EventRoot() : super("EventRoot");

  @override
  void onUpdate() {} // Finishしないように
}

// イベント自動実行マネージャー
class EventManager extends Component {
  // イベント全般で使うゲームオブジェクト
  static late MyGame myGame;

  int level;
  LevelEventBase levelEvent;

  // イベントはchildではなくこっちに登録する(childは全部実行される)
  EventRoot eventQueue = EventRoot();
  bool get isEmpty => !isNotEmpty;
  bool get isNotEmpty => eventQueue.hasChildren;

  EventManager(MyGame myGame, this.level) : levelEvent = getLevelEvent(level)! {
    // staticなメンバーに保存してEvent関係で使い回す
    // ignore: prefer_initializing_formals
    EventManager.myGame = myGame;

    add(eventQueue);
  }

  // イベントの場合はeventQueueに追加するように
  @override
  FutureOr<void> add(Component component) {
    if (component is EventRoot) {
      return super.add(component);
    }

    if (component is EventElement) {
      return eventQueue.add(component);
    } else {
      log.warning("event以外がaddされました: ${component.runtimeType}");
      return super.add(component);
    }
  }

  // イベントをDBから読み出して作成
  EventElement createFromDB(String eventName) {
    for (var info in eventInfo) {
      var result = myGame.memoryDB.select(
          "SELECT * FROM event.${info.table} WHERE level = ? AND name = ?",
          [myGame.event.level, eventName]);

      // イベントが複数あってはいけない
      if (result.length > 1) {
        log.warning("event duplicated: $eventName(${result.length})");
      }

      // イベントが見つかった
      if (result.isNotEmpty) {
        // nextがあれば用意しておく
        EventElement? next;
        if (result.first["next"] != null) {
          next = createFromDB(result.first["next"]);
        }

        // イベント生成
        return info.func(eventName, result.first[info.data], next);
      }
    }
    // 見知らぬイベント
    log.warning("event not found: $eventName");
    return EventElement("event not found");
  }

  // 通知あり登録したイベントが開始する時
  void onStartNotice(EventElement event) {
    levelEvent.onEventStart(event);
  }

  // 通知あり登録したイベントが終わった時
  void onFinishNitice(EventElement event) {
    levelEvent.onEventFinish(event);
  }
}

// [デバッグ用]イベント名の重複チェッカー
void checkDBEvents(CommonDatabase db, int level) {
  List<String> eventNames = [];

  for (var info in eventInfo) {
    // イベント名重複チェック
    var resultSet = db.select(
        "SELECT name FROM event.${info.table} WHERE level = ?", [level]);
    for (var result in resultSet) {
      if (eventNames.contains(result["name"])) {
        // イベント名が重複した
        log.warning("イベント名の重複: ${result["name"]}");
      } else {
        eventNames.add(result["name"]);
      }
    }
  }
}
