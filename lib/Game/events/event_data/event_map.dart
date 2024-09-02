import '../../ui_control.dart';
import '../event_element.dart';
import 'package:my_app/Game/player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

// 移動のみ(アクション用)
class EventMove extends EventElement {
  PlayerDir dir;
  EventMove(this.dir) : super("move: ${dir.toString()}");

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
  EventMoveToIdle(super.dir);

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
    String? name = gameRef.map.getEventProperty(blockX, blockY);
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

// マップ表示変更
class EventMapObjChange extends EventElement {
  int blockX, blockY;
  int gid;
  EventMapObjChange(this.gid, this.blockX, this.blockY)
      : super("map event change");

  @override
  void onStart() {
    gameRef.map.objs.tiles[blockY][blockX] = gid;
  }

  @override
  void onFinish() {
    gameRef.map.objs.updateSprites();
  }
}

// マップ移動変更
class EventMapMoveChange extends EventElement {
  int blockX, blockY;
  bool movable;
  EventMapMoveChange(this.movable, this.blockX, this.blockY)
      : super("map move change");

  @override
  void onStart() {
    gameRef.map.move.tiles[blockY][blockX] = movable ? 1 : 0;
  }
}
