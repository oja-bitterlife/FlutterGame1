import 'package:flutter/material.dart';
import '../my_game.dart';
import '../../UI_Widgets/message_window.dart';
import 'package:toml/toml.dart';
import 'package:flutter/services.dart';

import '../../my_logger.dart';

class Eventmanager {
  late MyGame myGame;

  late Map data;

  Eventmanager(this.myGame);

  static Future<Eventmanager> create(MyGame myGame) async {
    var self = Eventmanager(myGame);
    self.data = TomlDocument.parse(
            await rootBundle.loadString("assets/data/event.toml", cache: false))
        .toMap();
    return self;
  }

  Future<void> reload() async {}

  void onFind(int blockX, int blockY) {
    log.info(myGame.map.getEvent(blockX, blockY));

    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    // log.info(data["level1"]["MessageEvent"]["message"]);
    msgWin.currentState?.show(data["level1"]["MessageEvent"]["message"][0]);
  }
}
