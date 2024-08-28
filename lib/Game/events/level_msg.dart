import 'package:flutter/material.dart';
import '../../UI_Widgets/message_window.dart';

import 'package:my_app/Game/events/event_manager.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class EventMessage extends EventElement {
  static const String messageEventTable = "event.msg";

  // 表示UI
  late final MessageWindowState? msgWin;

  // 表示データ
  late final List<String> message;
  int page = 0;

  // 文字列フォーマッタ
  static List<String> format(String msg) {
    return msg.replaceAll("\\n", "\n").split("\\0");
  }

  EventMessage.fromString(String msg) : super("DynamicMessage") {
    message = format(msg);
    log.info("");
  }

  EventMessage.fromDB(super.name) {
    // イベントメッセージ出力
    var result = myGame.memoryDB.select(
        "select * from $messageEventTable where level = ? and name = ?",
        [myGame.eventManager.currentLevel, name]);

    // データを確認して開始
    if (result.isNotEmpty) {
      message = format(result.first["text"]);
      next = EventNext(result.first["next_type"], result.first["next_name"]);
    }
    // 該当するイベントデータが無かった
    else {
      message = ["メッセージデータがないイベントだ！: $name"];
    }

    // メッセージを表示
    msgWin =
        const GlobalObjectKey<MessageWindowState>("MessageWindow").currentState;
    nextPage();
  }

  // 次のメッセージ
  void nextPage() {
    if (page < message.length) {
      msgWin?.show(message[page]);
      page += 1;
    } else {
      finish();
    }
  }

  @override
  void stop() {
    msgWin?.hide();
    super.stop();
  }

  @override
  void finish() {
    msgWin?.hide();
    super.finish();
  }

  @override
  void update() {}
}
