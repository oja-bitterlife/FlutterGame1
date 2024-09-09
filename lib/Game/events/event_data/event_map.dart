import '../../ui_control.dart';
import '../event_element.dart';
import '/Game/player.dart';

// ignore: unused_import
import '/my_logger.dart';

// 移動のみ(アクション用)
class EventMove extends EventElement {
  PlayerDir dir;
  EventMove(this.dir, {super.notice}) : super("move: ${dir.toString()}");

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

// マップ表示変更
class EventMapObjChange extends EventElement {
  List<(int gid, int x, int y)> changeList = [];

  EventMapObjChange(this.changeList) : super("map_objs_change") {
    // オーバーレイを即変更
    for (var data in changeList) {
      gameRef.map.objs.overlay[data.$3][data.$2] = data.$1;
    }
    gameRef.map.objs.updateSprites();
  }

  @override
  void onStart() {
    // 確定させる
    gameRef.map.objs.applyOverlay();
  }
}

// マップ移動変更
class EventMapMoveChange extends EventElement {
  List<(bool movable, int x, int y)> changeList = [];

  EventMapMoveChange(this.changeList) : super("map_move_change") {
    // 移動も即変更(カーソル表示切り替え)
    for (var data in changeList) {
      gameRef.map.move.setMovable(data.$1, data.$2, data.$3);
    }
    gameRef.uiControl.cursor?.setAreaCursors();
  }
}
