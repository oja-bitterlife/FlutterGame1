import 'package:flame/components.dart';

import '../my_game.dart';

import 'event_element.dart';
import 'level_msg.dart';
import 'level_action.dart';

// ignore: unused_import
import '../../my_logger.dart';

class EventManager extends Component with HasGameRef<MyGame> {
  int currentLevel;

  EventManager(this.currentLevel);

  // イベントをDBから読み出して追加する
  void addEvent(String eventName) {
    const types = [
      "msg",
      "action",
    ];

    for (var type in types) {
      var result = gameRef.memoryDB.select(
          "select * from event.$type where level = ? and name = ?",
          [gameRef.eventManager.currentLevel, eventName]);

      // イベントが見つかった
      if (result.isNotEmpty) {
        EventElement? element = switch (type) {
          "msg" => EventMsgGroup(result.first["text"], result.first["next"]),
          "action" =>
            EventActionGroup(result.first["action"], result.first["next"]),
          _ => null,
        };
        if (element == null) continue;

        // イベント登録
        add(element);
        return;
      }
    }
    // 見知らぬイベント
    log.info("event not found: $eventName");
  }

  // Findアイコンが押された(イベントオブジェクトがある)
  void onFind(int blockX, int blockY) {
    String? name = gameRef.userData.mapEvent.get(blockX, blockY);
    log.info(name);
  }

  // 移動終了時イベント
  void onMoveFinish(int blockX, int blockY) {
    // move.onMoveFinish(blockX, blockY);
  }
}
