import 'package:flutter/material.dart';
import '../../../UI_Widgets/player_cursor.dart';

import 'package:my_app/Game/events/event_data/event_move.dart';
import 'package:my_app/Game/player.dart';

import '../event_element.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

// アクション一つ
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

class EventActionRoot extends EventElement {
  EventActionRoot(super.name, String action,
      [super.next, super.notify = true]) {
    addAll(formatEventAction(action).map((text) => EventAction(name, text)));
  }

  @override
  void onUpdate() {
    if (!hasChildren) finish();
  }

  @override
  void onFinish() {
    if (next == null) {
      var cursor =
          const GlobalObjectKey<PlayerCursorState>("PlayerCursor").currentState;
      cursor?.showFromArea();
    }
  }
}

// イベントマネージャ用
EventActionRoot createEventAction(String name, String action, String? next) {
  return EventActionRoot(name, action, next);
}
