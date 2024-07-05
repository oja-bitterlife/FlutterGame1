import 'package:my_app/Game/events/level1.dart';
import 'package:my_app/Game/events/level_event.dart';
import '../my_game.dart';

import '../../my_logger.dart';

class Eventmanager {
  late MyGame myGame;

  late LevelEvent event;

  Eventmanager(this.myGame);

  static Future<Eventmanager> create(MyGame myGame) async {
    var self = Eventmanager(myGame);
    self.event = await Level1.create();
    return self;
  }

  Future<void> reload() async {}

  void onFind(int blockX, int blockY) {
    log.info(myGame.map.getEvent(blockX, blockY));
    event.checkMsgEvent();
  }

  void onBeforIdle(int blockX, int blockY) {
    log.info(myGame.map.getEvent(blockX, blockY));
  }
}
