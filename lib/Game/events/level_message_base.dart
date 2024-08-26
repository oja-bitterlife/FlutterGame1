import 'package:flutter/material.dart';
import '../../UI_Widgets/message_window.dart';

import '../my_game.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class MessageView {
  final LevelMessageBase eventManager;

  final String type; // 実行イベント
  final List<String> message;
  final String? changeNext; // イベント変更先
  final int blockX, blockY; // イベント発生場所
  int page = 0;

  MessageView(this.eventManager, this.type, this.blockX, this.blockY,
      this.message, this.changeNext);

  // 次のメッセージを表示
  bool nextMessage() {
    // メッセージが空になら終了
    if (page >= message.length) {
      eventManager.onMessageFinish(type, blockX, blockY, changeNext);
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

  // メッセージ表示終了
  void close() {
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.hide();
  }
}

abstract class LevelMessageBase {
  static const messageEventTable = "event.message_event"; // メッセージデータ格納場所

  final MyGame myGame;
  final int level; // ステージ番号

  // メッセージウインドウ
  MessageView? messageView;
  bool get isPlaying => messageView != null;

  LevelMessageBase(this.myGame, this.level);

  // メッセージ表示終了
  void close() {
    messageView?.close();
    messageView = null;
  }

  // 文字列フォーマッタ
  List<String> format(String msg) {
    return msg.replaceAll("\\n", "\n").split("\\0");
  }

  // イベント再生
  void startEvent(String type, int blockX, int blockY) {
    var result = myGame.memoryDB.select(
        "select msg,next from $messageEventTable where name = ? and level = ?",
        [type, level]);

    // データを確認して開始
    if (result.isNotEmpty) {
      messageView = MessageView(this, type, blockX, blockY,
          format(result.first["msg"]), result.first["next"]);
      messageView?.start();
    } else {
      // tomlに該当するイベントデータが無かった
      startString(
          type, blockX, blockY, ["メッセージデータがないイベントだ！: $type($blockX, $blockY)"]);
    }
  }

  // 特別にメッセージを出したいとき
  void startString(String type, int blockX, int blockY, List<String> message,
      [String? changeNext]) {
    messageView = MessageView(this, type, blockX, blockY, message, changeNext);
    messageView?.start();
  }

  // イベントオブジェクトチェック
  void onFind(String type, int blockX, int blockY) {
    startString("no implemented: $type", blockX, blockY, ["未実装だ！"]);
  }

  // メッセージ表示終わりコールバック
  void onMessageFinish(
      String type, int blockX, int blockY, String? changeNext) {
    log.info("finish message: $type");
    close();

    // イベント更新
    if (changeNext != null) {
      myGame.userData.mapEvent.set(changeNext, blockX, blockY);
    }

    // メッセージが終わったらコマンド待ち
    myGame.startIdle();
  }
}
