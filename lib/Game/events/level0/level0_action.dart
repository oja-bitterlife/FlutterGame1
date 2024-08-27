import '../level_action_base.dart';
import '../../player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class EventOnStart extends LevelActionBase {
  EventOnStart() : super("on_start");

  @override
  void update() {
    if (name == "on_start") {
      if (myGame.player.getBlockY() > 10) {
        myGame.player.setMove(PlayerDir.up);
      } else {
        finish();
      }
    }
  }

  @override
  void onFinish() {
    super.onFinish();

    // アクションの次のイベントを発火
    // myGame.eventManager.startMessage(
    //     "on_start", myGame.player.getBlockX(), myGame.player.getBlockY());
  }
}
