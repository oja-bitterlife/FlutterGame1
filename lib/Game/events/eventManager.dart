import 'package:flutter/material.dart';
import '../my_game.dart';
import '../../UI_Widgets/message_window.dart';

import 'level1.dart';

class Eventmanager {
  late MyGame myGame;
  Eventmanager(MyGame game) {
    myGame = game;
  }

  void onFind() {
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState?.show(Level1Data().event.getMsg());
  }
}
