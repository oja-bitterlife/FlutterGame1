import 'package:flutter/material.dart';
import '../../UI_Widgets/message_window.dart';

import 'event_element.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class EventMsg extends EventElement {
  // 表示UI
  MessageWindowState? msgWin;
  String text;

  EventMsg(this.text) {
    msgWin =
        const GlobalObjectKey<MessageWindowState>("MessageWindow").currentState;
  }

  @override
  void onStart() {
    msgWin?.show(text);
  }

  @override
  void onUpdate() {
    if (gameRef.input.isTrgDown) {
      finish();
    }
  }
}

class EventMsgGroup extends EventQueue {
  // 文字列フォーマッタ
  static List<String> format(String msg) {
    return msg.replaceAll("\\n", "\n").split("\\0");
  }

  EventMsgGroup(String msg, [super.next]) {
    addAll(format(msg).map((text) => EventMsg(text)));
  }

  @override
  void onFinish() {
    var msgWin =
        const GlobalObjectKey<MessageWindowState>("MessageWindow").currentState;
    msgWin?.hide();

    super.onFinish();
  }
}
