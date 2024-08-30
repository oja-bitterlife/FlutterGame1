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

  void addEvent(String name) {
    const types = [
      "msg",
      "action",
    ];

    for (var type in types) {
      var result = gameRef.memoryDB.select(
          "select * from event.$type where level = ? and name = ?",
          [gameRef.eventManager.currentLevel, name]);

      // イベントが見つかった
      if (result.isNotEmpty) {
        EventElement element = switch (type) {
          "msg" =>
            EventMsgGroup(name, result.first["text"], result.first["next"]),
          "action" => EventActionGroup(
              name, result.first["action"], result.first["next"]),
          _ => EventElement.empty(),
        };
        if (element.isEmpty) {
          // 未実装のタイプ
          log.info("type not implement: $type");
        }

        // イベント登録
        add(element);
        return;
      }
    }
    // 見知らぬイベント
    log.info("event not found: $name");
  }

  // マップ上にイベントが存在するか調べる
  // String? getMapEvent(int blockX, int blockY) {
  //   // 上書きイベントを確認
  //   var eventName = gameRef.userData.mapEvent.get(blockX, blockY);
  //   if (eventName != null) return eventName; // イベント名を返す

  //   // マップのイベントを確認
  //   int gid = gameRef.map.getEventGid(blockX, blockY);
  //   if (gid != 0) {
  //     return gameRef.map.getTilesetProperty(gid, "event");
  //   }

  //   // イベントは特になかった
  //   return null;
  // }

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
