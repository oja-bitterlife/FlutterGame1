import 'package:flame/components.dart';
import 'package:my_app/Game/events/levels/level0.dart';
import 'package:sqlite3/wasm.dart';

import '../my_game.dart';

import 'event_element.dart';
import 'level_msg.dart';
import 'level_action.dart';

// ignore: unused_import
import '../../my_logger.dart';

import 'levels/level_base.dart';

class EventManager extends Component with HasGameRef<MyGame> {
  static const eventTypes = [
    "msg",
    "action",
  ];
  int currentLevel;

  LevelEventBase levelEvent;

  EventManager(MyGame myGame, this.currentLevel)
      : levelEvent = getLevelEvent(myGame, currentLevel)!;

  // イベント名の重複チェッカー
  static void checkDBEvents(CommonDatabase db, int level) {
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

  // イベントをDBから読み出して追加する
  void addEvent(String eventName) {
    for (var type in eventTypes) {
      var result = gameRef.memoryDB.select(
          "select * from event.$type where level = ? and name = ?",
          [gameRef.eventManager.currentLevel, eventName]);

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
    String? name = gameRef.userData.mapEvent.get(blockX, blockY);
    log.info(name);
  }

  void onEventFinish(EventElement event) {
    levelEvent.onEventFinish(event);
    log.info("finish ${event.name}(${event.runtimeType}) => ${event.next}");
  }
}
