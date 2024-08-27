import '../level_action_base.dart';
import '../../player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

import '../level_message_base.dart';

class EventOnStart extends LevelActionBase {
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
    myGame.eventManager.add(LevelMessageBase(0, "on_start"));
  }
}
