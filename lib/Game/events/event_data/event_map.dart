import '../../ui_control.dart';
import '../event_element.dart';
import 'package:my_app/Game/player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

// 移動のみ(アクション用)
class EventMove extends EventElement {
  PlayerDir dir;
  EventMove(this.dir, [String? next, bool notify = false])
      : super("move: ${dir.toString()}", next, notify);

  @override
  void onStart() {
    gameRef.uiControl.showUI = ShowUI.none;
    gameRef.player.setMove(dir);
  }

  @override
  void onUpdate() {
    if (!gameRef.player.isMoving) finish();
  }
}

// 移動後カーソル表示
class EventMoveToIdle extends EventMove {
  EventMoveToIdle(super.dir, [super.next, super.notify = true]);

  @override
  void onFinish() {
    gameRef.uiControl.showUI = ShowUI.cursor;
  }
}

// 調べた後カーソル表示
class EventFindToIdle extends EventElement {
  int blockX, blockY;
  EventFindToIdle(this.blockX, this.blockY) : super("find");

  @override
  void onStart() {
    String? name = gameRef.map.getEventName(blockX, blockY);
    if (name != null) {
      gameRef.eventManager.addEvent(changeMapEvent(name));
    }
    // finish();
  }

  // itemの状態によってマップイベントを変更する
  String changeMapEvent(String name) {
    var results = gameRef.memoryDB.select(
        "SELECT * FROM event.map WHERE name = ? ORDER BY priority DESC",
        [name]);

    for (var result in results) {
      // アイテム保有時
      if (result["own"] != null) {
        if (gameRef.userData.items.isOwned(result["own"])) {
          return result["next"];
        }
      }

      // アイテム使用時
      if (result["used"] != null) {
        if (gameRef.userData.items.isUsed(result["used"])) {
          return result["next"];
        }
      }
    }

    // 元のまま使う
    return name;
  }
}
