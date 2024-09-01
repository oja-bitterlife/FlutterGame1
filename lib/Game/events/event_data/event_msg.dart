import 'package:flutter/material.dart';
import '../../../UI_Widgets/message_window.dart';

import '../event_element.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

// メッセージ1つ表示
class EventMsg extends EventElement {
  // 表示UI
  MessageWindowState? msgWin;
  String text;

  EventMsg(super.name, this.text) {
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

// 複数メッセージを順番に表示
class EventMsgGroup extends EventQueue {
  // 文字列フォーマッタ
  static List<String> format(String msg) {
    return msg.replaceAll("\\n", "\n").split("\\0");
  }

  EventMsgGroup(super.name, String msg, [super.next]) {
    addAll(format(msg).map((text) => EventMsg(name, text)));
  }

  @override
  void onFinish() {
    var msgWin =
        const GlobalObjectKey<MessageWindowState>("MessageWindow").currentState;
    msgWin?.hide();
  }
}

// イベントマネージャ用
EventMsgGroup createEventMsg(String name, String text, String? next) =>
    EventMsgGroup(name, text, next);
