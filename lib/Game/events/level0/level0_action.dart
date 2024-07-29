import '../level_action_base.dart';
import '../../my_game.dart';
import '../../player.dart';

class Level0Action extends LevelActionBase {
  Level0Action(super.myGame);

  static create(MyGame myGame) async {
    var self = Level0Action(myGame);
    return self;
  }

  @override
  void update() {
    if (type == "start") {
      if (myGame.player.getBlockY() < 12) {
        myGame.player.setMove(PlayerDir.up);
      } else {
        onActionFinish(type);
      }
    }
  }

  @override
  void onActionFinish(String type) {
    this.type = "";
  }
}
