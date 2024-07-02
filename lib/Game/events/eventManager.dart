import 'package:flutter/material.dart';
import '../my_game.dart';
import '../../UI_Widgets/message_window.dart';
import 'package:toml/toml.dart';
import 'package:flutter/services.dart';

import '../../my_logger.dart';

class Eventmanager {
  late Map data;

  late MyGame myGame;
  Eventmanager(this.myGame);

  static Future<Eventmanager> create(MyGame myGame) async {
    var self = Eventmanager(myGame);
    var toml = await rootBundle.loadString("assets/data/event.toml");
    self.data = TomlDocument.parse(toml).toMap();
    return self;
  }

  void onFind(int blockX, int blockY) {
    log.info(myGame.map.getEvent(blockX, blockY));

    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    log.info(data["level1"]["MessageEvent"]["message"]);
    // msgWin.currentState?.show(data[]);
  }
}
