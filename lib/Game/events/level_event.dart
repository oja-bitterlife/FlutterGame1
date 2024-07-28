import 'package:flutter/material.dart';
import '../../UI_Widgets/message_window.dart';

import '../../Game/my_game.dart';

// ignore: unused_import
import '../../my_logger.dart';

class MessageEvent {
  final LevelEvent eventManager;

  final String type;
  final List<String> message;
  int page = 0;

  MessageEvent(this.eventManager, this.type, this.message);

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

  bool startMessage({int page = 0}) {
    this.page = page;
    return nextMessage(); // 最初のメッセージ表示
  }
}

abstract class LevelEvent {
  final MyGame myGame;
  final Map levelEventData;

  MessageEvent? messageEvent;

  LevelEvent(this.myGame, this.levelEventData);

  // tomlデータのイベント再生
  void startMessageEvent(String type) {
    // データを確認して開始
    if (Map<String, dynamic>.from(levelEventData["messageEvent"])
        .containsKey(type)) {
      // メッセージイベントは同じ構造であること
      messageEvent = MessageEvent(
          this, type, List<String>.from(levelEventData["messageEvent"][type]));
      messageEvent?.startMessage();
    } else {
      // tomlに該当するイベントデータが無かった
      addMessageEvent(type, ["データにないイベントだ！"]);
    }
  }

  // 特別にメッセージを出したいとき
  void addMessageEvent(String type, List<String> message) {
    messageEvent = MessageEvent(this, type, message);
    messageEvent?.startMessage();
  }

  // イベントオブジェクトチェック
  void onFind(String type, int blockX, int blockY) {
    addMessageEvent("no implemented", ["未実装だ！"]);
  }

  // 移動後チェック
  void onMoved(int blockX, int blockY) {
    // 待機開始
    myGame.startIdle();
  }

  // メッセージ表示終わりコールバック
  void onMessageFinish(String type) {
    // メッセージを表示し終わっていたらhide
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.hide();

    // idle開始
    myGame.startIdle();
  }
}
