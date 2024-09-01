import 'package:flutter/material.dart';
import '../../../UI_Widgets/message_window.dart';
import '../../../UI_Widgets/player_cursor.dart';

import '../event_element.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

// メッセージ1つ表示
class EventMsg extends EventElement {
  // 表示UI
  String text;

  EventMsg(super.name, this.text, [super.next, super.notify]);

  @override
  void onStart() {
    var cursor =
        const GlobalObjectKey<PlayerCursorState>("PlayerCursor").currentState;
    cursor?.hide();

    var msgWin =
        const GlobalObjectKey<MessageWindowState>("MessageWindow").currentState;
    msgWin?.show(text);
  }

  @override
  void onUpdate() {
    if (gameRef.input.isTrgDown) {
      finish();
    }
  }
}

class EventMsgRoot extends EventElement {
  EventMsgRoot(super.name, String text, [super.next, super.notify = true]) {
    addAll(formatEventMsg(text).map((text) => EventMsg(name, text)));
  }

  @override
  void onUpdate() {
    if (!hasChildren) {
      var msgWin = const GlobalObjectKey<MessageWindowState>("MessageWindow")
          .currentState;
      msgWin?.hide();

      finish();
    }
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

List<String> formatEventMsg(String text) {
  return text.replaceAll("\\n", "\n").split("\\0");
}

EventMsgRoot createEventMsg(String name, String text, String? next) {
  return EventMsgRoot(name, text, next);
}
