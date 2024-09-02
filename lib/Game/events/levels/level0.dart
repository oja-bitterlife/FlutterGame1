import 'package:my_app/Game/events/event_data/event_map.dart';
import 'package:my_app/Game/ui_control.dart';

import 'level_base.dart';
import 'package:my_app/Game/events/event_element.dart';

// ignore: unused_import
import '../../../my_logger.dart';

class Level0 extends LevelEventBase {
  Level0(super.myGame);

  @override
  void onEventStart(EventElement event) {
    if (event.name == "treasure") {
      // メッセージ表示前に表示変更
      myGame.event.add(EventMapObjChange(myGame, 374,
          myGame.player.getFowardBlockX(), myGame.player.getFowardBlockY()));
    }
  }

  @override
  void onEventFinish(EventElement event) {
    if (event.name == "treasure") {
      myGame.userData.items.obtain("key");
    }
    if (event.name == "gate_with_key") {
      myGame.userData.items.use("key");

      // 表示変更
      myGame.event.add(EventMapObjChange(
          myGame,
          424,
          myGame.player.getFowardBlockX(),
          myGame.player.getFowardBlockY() - 1));
    }

    if (event.name == "trap") {
      log.info("game over");
    }

    log.info(event);
    if (event is EventMove) {
      if (myGame.map.getGid(
              "trap", myGame.player.getBlockX(), myGame.player.getBlockY()) !=
          0) {
        myGame.event.add(myGame.event.createFromDB("trap"));

        // UIを消した状態にする
        myGame.uiControl.showUI = ShowUI.none;
      }
    }
  }
}
