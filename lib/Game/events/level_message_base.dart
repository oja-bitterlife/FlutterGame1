import 'package:flutter/material.dart';
import '../../UI_Widgets/message_window.dart';

import 'package:my_app/Game/events/event_manager.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class LevelMessageBase extends EventElement {
  static const String messageTable = "event.message_event";

  // 表示UI
  late final MessageWindowState? msgWin;

  // 表示データ
  late final List<String> message;
  int page = 0;
  String? changeMapEvent;

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

    // メッセージを表示
    msgWin =
        const GlobalObjectKey<MessageWindowState>("MessageWindow").currentState;
    msgWin?.show(message[page]);
  }

  // 次のメッセージ
  void _showNext() {
    page += 1;
    msgWin?.show(message[page]);
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
  void onFinish() {
    super.onFinish();

    // マップイベントを更新
    if (changeMapEvent != null) {
      // var result = myGame.memoryDB.select(
      //     "select msg,next from $messageTable where name = ? and level = ?",
      //     [name, level]);
    }
  }

  @override
  void update() {
    // 入力チェック
    // if (マウス入力があった) {
    //   if (page < message.length) _showNext();
    //   else finish();
    // }
  }
}
