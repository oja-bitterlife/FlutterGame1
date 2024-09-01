import 'package:flame/components.dart';
import 'package:sqlite3/wasm.dart';

import '../my_game.dart';

import 'event_element.dart';
import 'event_data/event_msg.dart';
import 'event_data/event_action.dart';

// ignore: unused_import
import '../../my_logger.dart';

import 'levels/level_base.dart';

const eventTypes = [
  "msg",
  "action",
];

class EventManager extends Component with HasGameRef<MyGame> {
  int level;
  LevelEventBase levelEvent;

  EventManager(MyGame myGame, this.level)
      : levelEvent = getLevelEvent(myGame, level)!;

  // イベントをDBから読み出して追加する
  void addEvent(String eventName) {
    for (var type in eventTypes) {
      var result = gameRef.memoryDB.select(
          "SELECT * FROM event.$type WHERE level = ? AND name = ?",
          [gameRef.eventManager.level, eventName]);

      // イベントが見つかった
      if (result.isNotEmpty) {
        EventElement? element = switch (type) {
          "msg" => EventMsgGroup(
              eventName, result.first["text"], result.first["next"]),
          "action" => EventActionGroup(
              eventName, result.first["action"], result.first["next"]),
          _ => null,
        };
        if (element == null) continue;

        // イベント登録
        add(element);
        return;
      }
    }
    // 見知らぬイベント
    log.warning("event not found: $eventName");
  }

  // Findアイコンが押された(イベントオブジェクトがある)
  void onFind(int blockX, int blockY) {
    String? name = gameRef.map.getEventName(blockX, blockY);
    if (name != null) {
      addEvent(changeMapEvent(gameRef, name));
    }
  }

  // 登録したイベントが終わった時
  void onEventFinish(EventElement event) {
    levelEvent.onEventFinish(event);
    log.info("finish ${event.name}(${event.runtimeType}) => ${event.next}");
  }
}

// itemの状態によってマップイベントを変更する
String changeMapEvent(MyGame myGame, String name) {
  var results = myGame.memoryDB.select(
      "SELECT * FROM event.map WHERE name = ? ORDER BY priority DESC", [name]);

  for (var result in results) {
    // アイテム保有時
    if (result["own"] != null) {
      if (myGame.userData.items.isOwned(result["own"])) {
        return result["next"];
      }
    }

    // アイテム使用時
    if (result["used"] != null) {
      if (myGame.userData.items.isUsed(result["used"])) {
        return result["next"];
      }
    }
  }

  // 元のまま使う
  return name;
}

// イベント名の重複チェッカー
void checkDBEvents(CommonDatabase db, int level) {
  List<String> eventNames = [];

  for (var type in eventTypes) {
    // イベント名重複チェック
    var resultSet =
        db.select("SELECT name FROM event.$type WHERE level = ?", [level]);
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
