import 'package:flutter/material.dart';
import '../../UI_Widgets/message_window.dart';

import '../my_game.dart';
import 'event_element.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class EventMsg extends EventElement {
  // 表示UI
  MessageWindowState? msgWin;
  String text;

  EventMsg(MyGame myGame, String name, this.text) : super(myGame, "msg", name) {
    msgWin =
        const GlobalObjectKey<MessageWindowState>("MessageWindow").currentState;
  }

  @override
  void onStart() {
    msgWin?.show(text);
  }

  @override
  void onUpdate() {
    if (myGame.input.isTrgDown) {
      finish();
    }
  }
}

class EventMsgGroup extends EventQueue {
  static const String messageEventTable = "event.msg";

  // 文字列フォーマッタ
  static List<String> format(String msg) {
    return msg.replaceAll("\\n", "\n").split("\\0");
  }

  EventMsgGroup.fromString(MyGame myGame, String msg)
      : super(myGame, "msg", "String") {
    addAll(format(msg).map((text) => EventMsg(myGame, current.name!, text)));
  }

  EventMsgGroup.fromDB(MyGame myGame, String name)
      : super(myGame, "msg", name) {
    // イベントメッセージ出力
    var result = myGame.memoryDB.select(
        "select * from $messageEventTable where level = ? and name = ?",
        [myGame.eventManager.currentLevel, name]);

    // データを確認して開始
    if (result.isNotEmpty) {
      addAll(format(result.first["text"])
          .map((text) => EventMsg(myGame, current.name!, text)));
      next = (type: result.first["next_type"], name: result.first["next_name"]);
    }
    // 該当するイベントデータが無かった
    else {
      add(EventMsg(myGame, "Error", "メッセージデータがないイベントだ！: $name"));
    }
  }

  @override
  void stop() {
    var msgWin =
        const GlobalObjectKey<MessageWindowState>("MessageWindow").currentState;
    msgWin?.hide();

    super.stop();
  }

  @override
  void finish() {
    var msgWin =
        const GlobalObjectKey<MessageWindowState>("MessageWindow").currentState;
    msgWin?.hide();

    super.finish();
  }
}
