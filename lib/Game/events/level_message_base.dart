import 'package:flutter/material.dart';
import '../../UI_Widgets/message_window.dart';

import 'package:my_app/Game/events/event_manager.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class LevelMessageBase extends EventElement {
  static const String messageTable = "event.message_event";

  late final List<String> message;
  int page = 0;
  String? changeMapEvent;

  bool get isFinish => !isNotFinish;
  bool get isNotFinish => page < message.length;

  // 文字列フォーマッタ
  static List<String> format(String msg) {
    return msg.replaceAll("\\n", "\n").split("\\0");
  }

  LevelMessageBase(int level, super.name,
      [String? msg, String? changeMapEvent]) {
    // 動的メッセージ出力
    if (msg != null) {
      message = format(msg);
      this.changeMapEvent = changeMapEvent;
    }
    // イベントメッセージ出力
    else {
      var result = myGame.memoryDB.select(
          "select msg,next from $messageTable where name = ? and level = ?",
          [name, level]);

      // データを確認して開始
      if (result.isNotEmpty) {
        message = format(result.first["msg"]);
        changeMapEvent = result.first["next"];
      } else {
        // tomlに該当するイベントデータが無かった
        message = ["メッセージデータがないイベントだ！: $name"];
      }
    }

    // メッセージを表示して次へ
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.show(message[page]);
  }

  @override
  void stop() {
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.hide();

    super.stop();
  }

  @override
  void finish() {
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.hide();

    super.finish();
  }

  @override
  void onFinish() {
    super.onFinish();

    // マップイベントを更新
    if (changeMapEvent != null) {
      // var result = myGame.memoryDB.select(
      //     "select msg,next from $messageTable where name = ? and level = ?",
      //     [name, level]);
    }
  }

  void next() {
    // 次のメッセージ
    page += 1;
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.show(message[page]);
  }

  @override
  void update() {
    if (isFinish) {
      finish();
      return;
    }
  }
}
