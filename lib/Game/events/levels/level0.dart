import 'package:my_app/Game/events/event_data/event_map.dart';
import 'package:my_app/Game/ui_control.dart';

import 'level_base.dart';
import 'package:my_app/Game/events/event_element.dart';

// ignore: unused_import
import '../../../my_logger.dart';

class Level0 extends LevelEventBase {
  Level0(super.myGame);

  @override
  void onEventFinish(EventElement event) {
    if (event.name == "treasure") {
      myGame.userData.items.obtain("key");
      myGame.eventManager.add(EventMapObjChange(374,
          myGame.player.getFowardBlockX(), myGame.player.getFowardBlockY()));
    }
    if (event.name == "gate_with_key") {
      myGame.userData.items.use("key");
      myGame.eventManager.add(EventMapObjChange(
          424,
          myGame.player.getFowardBlockX(),
          myGame.player.getFowardBlockY() - 1));
    }

    if (event.name == "trap") {
      log.info("game over");
    }

    if (event is EventMove) {
      if (myGame.map.getGid(
              "trap", myGame.player.getBlockX(), myGame.player.getBlockY()) !=
          0) {
        myGame.eventManager.addEvent("trap");

        // UIを消した状態にする
        myGame.uiControl.showUI = ShowUI.none;
      }
    }
  }
}
