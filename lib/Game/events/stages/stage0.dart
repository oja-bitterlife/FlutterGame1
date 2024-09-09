import 'package:flame/components.dart';
import '/Game/events/event_data/event_map.dart';
import '/Game/ui_control.dart';

import 'stage_base.dart';
import '/Game/events/event_element.dart';

// ignore: unused_import
import '../../../my_logger.dart';

import '../../priorities.dart';

class Stage0 extends StageEventBase {
  Stage0() : super('Tutorial');

  @override
  void onEventStart(EventElement event) {
    if (event.name == "treasure") {
      // メッセージ表示前にマップ表示変更
      myGame.event.add(EventMapObjChange([
        (374, myGame.player.getFowardBlockX(), myGame.player.getFowardBlockY())
      ]));
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
      myGame.event.add(EventMapObjChange([
        (
          424,
          myGame.player.getFowardBlockX(),
          myGame.player.getFowardBlockY() - 1
        )
      ]));
      // ドア表示切り替え
      myGame.event.add(EventMapObjChange([(178, 7, 2)]));
      myGame.event.add(EventMapObjChange([(190, 7, 3)]));
      // 移動切り替え
      myGame.event.add(EventMapMoveChange([(true, 7, 3)]));
    }

    if (event.name == "trap") {
      log.info("game over");
      myGame.uiControl.showUI = ShowUI.none;
    }
    if (event.name == "clear") {
      log.info("game clear");
      myGame.uiControl.showUI = ShowUI.none;
    }

    // 移動終わりイベント
    if (event is EventUserMove) {
      if (myGame.map.getGid(
              "trap", myGame.player.getBlockX(), myGame.player.getBlockY()) !=
          0) {
        var trapEvent = myGame.event.createFromDB("trap");
        trapEvent.notice = true;
        myGame.event.add(trapEvent);

        // トラップ表示
        myGame.add(SpriteComponent(
            priority: Priority.eventOver.index,
            position: myGame.player.position - Vector2(26, 48),
            scale: Vector2.all(1.5),
            sprite: Sprite(myGame.trapSheet.image,
                srcPosition: Vector2(160, 512), srcSize: Vector2.all(48))));

        // UIを消した状態にする
        myGame.uiControl.showUI = ShowUI.none;
      }

      // ゲームクリア表示
      if (myGame.player.getBlockX() == 7 && myGame.player.getBlockY() == 3) {
        var clearEvent = EventElement("clear");
        clearEvent.notice = true;
        myGame.event.add(clearEvent);

        // UIを消した状態にする
        myGame.uiControl.showUI = ShowUI.none;
      }
    }
  }
}
