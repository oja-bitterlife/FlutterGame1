import 'package:flutter/material.dart';
import '../my_game.dart';
import '../../UI_Widgets/message_window.dart';

import 'level1.dart';
import '../../my_logger.dart';

class Eventmanager {
  late MyGame myGame;
  Eventmanager(this.myGame);

  void onFind(int blockX, int blockY) {
    log.info(myGame.map.getEvent(blockX, blockY));

    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.show(Level1Data().event.getMsg());
  }
}
