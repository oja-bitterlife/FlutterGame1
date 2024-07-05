import 'package:flutter/material.dart';

import '../my_game.dart';
import '../../UI_Widgets/message_window.dart';
import 'level_event.dart';

import 'level1.dart';

// ignore: unused_import
import '../../my_logger.dart';

class Eventmanager {
  late MyGame myGame;

  late LevelEvent event;
  List<String> msg = [];

  Eventmanager(this.myGame);

  static Future<Eventmanager> create(MyGame myGame) async {
    var self = Eventmanager(myGame);
    self.event = await Level1.create(myGame);
    return self;
  }

  Future<void> reload() async {}

  void onFind(int blockX, int blockY) {
    String? type = myGame.map.getEvent(blockX, blockY);
    if (type != null) {
      event.onFind(blockX, blockY);
    }
  }

  bool onBeforIdle(int blockX, int blockY) {
    return event.checkIdleEvent(blockX, blockY);
  }

  // 次のメッセージを表示
  void nextMsg() {
    // メッセージが空になら終了
    if (msg.isEmpty) {
      myGame.startIdle();
      return;
    }

    // メッセージを表示して前詰め
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.show(msg[0]);
    msg.removeAt(0);
  }

  void startMsgList(List<String> msg) {
    this.msg = msg;
    nextMsg(); // 最初のメッセージ表示
  }
}
