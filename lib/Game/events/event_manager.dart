import 'package:flame/components.dart';
import 'package:sqlite3/wasm.dart';

import '../my_game.dart';

import 'event_element.dart';
import 'level_msg.dart';
import 'level_action.dart';

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
          "select * from event.$type where level = ? and name = ?",
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
      addEvent(name);
    }
  }

  // 登録したイベントが終わった時
  void onEventFinish(EventElement event) {
    levelEvent.onEventFinish(event);
    log.info("finish ${event.name}(${event.runtimeType}) => ${event.next}");
  }
}

// イベント名の重複チェッカー
void checkDBEvents(CommonDatabase db, int level) {
  List<String> eventNames = [];

  for (var type in eventTypes) {
    // イベント名重複チェック
    var resultSet =
        db.select("select name from event.$type where level = ?", [level]);
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
