import '../level_action_base.dart';
import '../../my_game.dart';
import '../../player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class Level0Action extends LevelActionBase {
  Level0Action(super.myGame);

  static create(MyGame myGame) async {
    var self = Level0Action(myGame);
    return self;
  }

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
    myGame.eventManager.startMessage(
        "on_start", myGame.player.getBlockX(), myGame.player.getBlockY());
  }
}
