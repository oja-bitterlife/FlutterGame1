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
class EventManager extends Component with HasGameRef<MyGame> {
  int level;
  LevelEventBase levelEvent;

  // イベントはchildではなくこっちに登録する(childは全部実行される)
  EventElement eventQueue;

  EventManager(MyGame myGame, this.level)
      : eventQueue = EventRoot(),
        levelEvent = getLevelEvent(myGame, level)! {
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

  // イベントをDBから読み出して追加する
  void addEvent(String eventName) {
    for (var info in eventInfo) {
      var result = gameRef.memoryDB.select(
          "SELECT * FROM event.${info.table} WHERE level = ? AND name = ?",
          [gameRef.eventManager.level, eventName]);

      // イベントが複数あってはいけない
      if (result.length > 1) {
        log.warning("event duplicated: $eventName(${result.length})");
      }

      // イベントが見つかった
      if (result.isNotEmpty) {
        // イベント登録
        add(info.func(
            eventName, result.first[info.data], result.first["next"]));
        return;
      }
    }
    // 見知らぬイベント
    log.warning("event not found: $eventName");
  }

  // 通知あり登録したイベントが開始する時
  void onStartNotice(EventElement event) {
    log.info(
        "notice-start ${event.name}(${event.runtimeType}) => ${event.next}");
    levelEvent.onEventStart(event);
  }

  // 通知あり登録したイベントが終わった時
  void onFinishNitice(EventElement event) {
    log.info(
        "notice-finish ${event.name}(${event.runtimeType}) => ${event.next}");
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
