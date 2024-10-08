import '/Game/events/event_data/event_map.dart';
import '/Game/player.dart';

import '../../ui_control.dart';
import '../event_element.dart';

// ignore: unused_import
import '/my_logger.dart';

// アクション一つ設定
class EventAction extends EventElement {
  String command;
  EventAction(super.name, this.command) {
    switch (command) {
      case "UP":
        add(EventMove(PlayerDir.up));
      case "DOWN":
        add(EventMove(PlayerDir.down));
      case "LEFT":
        add(EventMove(PlayerDir.left));
      case "RIGHT":
        add(EventMove(PlayerDir.right));
    }
  }

  @override
  void onUpdate() {
    // イベント完了
    if (!hasChildren) finish();
  }
}

List<String> formatEventAction(String action) {
  return action.split(",");
}

// 一連のアクション設定
class EventActionRoot extends EventElement {
  EventActionRoot(super.name, String action, {super.next}) {
    addAll(formatEventAction(action).map((text) => EventAction(name, text)));
  }

  @override
  void onUpdate() {
    if (!hasChildren) finish();
  }

  @override
  void onFinish() {
    if (next == null) {
      gameRef.uiControl.showUI = ShowUI.cursor;
    }
  }
}

// イベントマネージャ用
EventActionRoot createEventAction(
    String name, String data, EventElement? next) {
  return EventActionRoot(name, data, next: next);
}
