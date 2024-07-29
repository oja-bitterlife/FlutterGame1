import 'package:flutter/material.dart';
import '../../UI_Widgets/message_window.dart';

import '../my_game.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class MessageView {
  final LevelMessageBase eventManager;

  final String type;
  final List<String> message;
  int page = 0;

  MessageView(this.eventManager, this.type, this.message);

  // 次のメッセージを表示
  bool nextMessage() {
    // メッセージが空になら終了
    if (page >= message.length) {
      eventManager.onMessageFinish(type);
      return false;
    }

    // メッセージを表示して次へ
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.show(message[page]);
    page += 1;

    return true;
  }

  bool start({int page = 0}) {
    this.page = page;
    return nextMessage(); // 最初のメッセージ表示
  }

  void close() {
    // メッセージを表示し終わっていたらhide
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.hide();
  }
}

abstract class LevelMessageBase {
  final MyGame myGame;
  final Map levelEventData;

  // メッセージウインドウ
  MessageView? messageView;
  bool get isPlaying => messageView != null;

  LevelMessageBase(this.myGame, this.levelEventData);

  // tomlデータのイベント再生
  void startEvent(String type) {
    // データを確認して開始
    if (Map<String, dynamic>.from(levelEventData["messageEvent"])
        .containsKey(type)) {
      // メッセージイベントは同じ構造であること
      messageView = MessageView(
          this, type, List<String>.from(levelEventData["messageEvent"][type]));
      messageView?.start();
    } else {
      // tomlに該当するイベントデータが無かった
      startString(type, ["メッセージデータがないイベントだ！: $type"]);
    }
  }

  // 特別にメッセージを出したいとき
  void startString(String type, List<String> message) {
    messageView = MessageView(this, type, message);
    messageView?.start();
  }

  // イベントオブジェクトチェック
  void onFind(String type, int blockX, int blockY) {
    // メッセージイベントだった
    if (Map<String, dynamic>.from(levelEventData["messageEvent"])
        .containsKey(type)) {
      startEvent(type);
      return;
    }

    // 未実装イベント
    startString("no implemented", ["未実装だ！"]);
  }

  // メッセージ表示終わりコールバック
  void onMessageFinish(String type) {
    log.info("finish message: $type");

    messageView?.close();
    messageView = null;

    // idle開始
    myGame.eventManager
        .onIdle(myGame.player.getBlockX(), myGame.player.getBlockY());
  }
}
