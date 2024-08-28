import 'package:my_app/Game/events/event_manager.dart';

import '../level_action.dart';
import '../../player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class EventOnStart extends EventAction {
  EventOnStart() : super("on_start");

  @override
  void update() {
    if (name == "on_start") {
      if (myGame.player.getBlockY() > 10) {
        myGame.player.setMove(PlayerDir.up);
      } else {
        // 移動が終わるのを待ってFinish
        if (!myGame.player.isMoving()) finish();
      }
    }
  }

  @override
  void onFinish() {
    super.onFinish();

    // アクションの次のイベントを発火
    // myGame.eventManager.add(EventMessage.fromDB(0, "on_start"));
  }
}

EventElement? getEventLv0(String type, String name) {
  if (type == "action") {
    if (name == "on_start") {
      return EventOnStart();
    }
  }

  return null;
}
