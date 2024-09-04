import 'package:my_app/Game/events/event_data/event_map.dart';
import 'package:my_app/Game/ui_control.dart';

import 'level_base.dart';
import 'package:my_app/Game/events/event_element.dart';

// ignore: unused_import
import '../../../my_logger.dart';

class Level0 extends LevelEventBase {
  @override
  void onEventStart(EventElement event) {
    if (event.name == "treasure") {
      // メッセージ表示前にマップ表示変更
      myGame.event.add(EventMapObjChange(374, myGame.player.getFowardBlockX(),
          myGame.player.getFowardBlockY()));
    }
  }

  @override
  void onEventFinish(EventElement event) {
    if (event.name == "treasure") {
      myGame.userData.items.obtain("key");
    }

    if (event.name == "gate_with_key") {
      myGame.userData.items.use("key");
      // センサー表示切り替え
      myGame.event.add(EventMapObjChange(424, myGame.player.getFowardBlockX(),
          myGame.player.getFowardBlockY() - 1));
      // ドア表示切り替え
      myGame.event.add(EventMapObjChange(178, 7, 2));
      myGame.event.add(EventMapObjChange(190, 7, 3));
    }

    if (event.name == "trap") {
      log.info("game over");
      super.onEventFinish(event);
    }

    // 移動終わりイベント
    if (event is EventUserMove) {
      if (myGame.map.getGid(
              "trap", myGame.player.getBlockX(), myGame.player.getBlockY()) !=
          0) {
        var trapEvent = myGame.event.createFromDB("trap");
        trapEvent.notice = true;
        event.next = trapEvent;
        // myGame.event.add(trapEvent);

        // UIを消した状態にする
        myGame.uiControl.showUI = ShowUI.none;
      }
    }
  }
}
