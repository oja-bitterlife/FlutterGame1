import '../level_action_base.dart';
import '../../my_game.dart';
import '../../player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class Level0Action extends LevelActionBase {
  Level0Action(MyGame myGame) : super(myGame, 0);

  @override
  void update() {
    if (type == "on_start") {
      if (myGame.player.getBlockY() > 10) {
        myGame.player.setMove(PlayerDir.up);
      } else {
        onActionFinish(type);
      }
    }
  }

  @override
  void onActionFinish(String type) {
    super.onActionFinish(type);

    // アクションの次のイベントを発火
    myGame.eventManager.startMessage(
        "on_start", myGame.player.getBlockX(), myGame.player.getBlockY());
  }
}
