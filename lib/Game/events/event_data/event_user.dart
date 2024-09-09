import '../../ui_control.dart';
import '../event_element.dart';
import 'event_map.dart';

// ignore: unused_import
import '/my_logger.dart';

// ユーザー入力移動。移動後にカーソル表示
class EventUserMove extends EventMove {
  // ユーザー入力イベントは通知を行う
  EventUserMove(super.dir) : super(notice: true);

  @override
  void onFinish() {
    gameRef.uiControl.showUI = ShowUI.cursor;
  }
}

// 調べた後カーソル表示
class EventUserFind extends EventElement {
  String? eventName;
  int blockX, blockY;

  // ユーザー入力イベントは通知を行う
  EventUserFind(this.blockX, this.blockY)
      : super("event not found", notice: true) {
    eventName = gameRef.map.getEventProperty(blockX, blockY);

    // イベントがあったので名前をちゃんと設定する
    if (eventName != null) super.name = eventName!;
  }

  @override
  void onStart() {
    // 調べた先のイベントを再生
    if (eventName != null) {
      var event = eventRef.createFromDB(changeMapEvent(eventName!));
      event.notice = true; // Findの一環なので通知をONに
      add(event);
    }
  }

  @override
  void onFinish() {
    // Idleに強制する
    gameRef.uiControl.showUI = ShowUI.cursor;
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
