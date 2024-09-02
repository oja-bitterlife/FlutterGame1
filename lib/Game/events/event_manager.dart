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
    // eventQueueをaddするとeventQueueへのaddがgameにaddするようになる
    // mountされなければいいのでaddせず、不便なのでgameRefは拾えるようにする
    eventQueue.game = myGame;
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

  @override
  void updateTree(double dt) {
    super.updateTree(dt);

    // イベントキューはaddしてないので手動で
    eventQueue.updateTree(dt);
  }

  // イベントをDBから読み出して作成
  EventElement createFromDB(String eventName) {
    for (var info in eventInfo) {
      var result = gameRef.memoryDB.select(
          "SELECT * FROM event.${info.table} WHERE level = ? AND name = ?",
          [gameRef.event.level, eventName]);

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
    log.info(
        "notice_start ${event.name}(${event.runtimeType}) => ${event.next}");
    levelEvent.onEventStart(event);
  }

  // 通知あり登録したイベントが終わった時
  void onFinishNitice(EventElement event) {
    log.info(
        "notice_finish ${event.name}(${event.runtimeType}) => ${event.next}");
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
