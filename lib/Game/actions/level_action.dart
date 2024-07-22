import 'package:my_app/Game/my_game.dart';
import 'package:my_app/Game/player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

abstract class LevelAction {
  final MyGame myGame;
  String? actionName;
  int actionStep = 0;

  LevelAction(this.myGame);

  bool get isPlaying {
    return actionName != null;
  }

  // アクションを開始する
  void startAction(String actionName) {
    log.info("start action");
    this.actionName = actionName;
    actionStep = 0;
    myGame.startIdle();
  }

  // アクションを終了して入力待ちにする
  void endAction() {
    actionName = null;
    myGame.startIdle();
  }

  void playAction();
}

class Level1Action extends LevelAction {
  Level1Action(super.myGame);

  @override
  void playAction() {
    switch (actionName) {
      case "onStart":
        playOnStart();
    }
  }

  void playOnStart() {
    switch (actionStep) {
      case 0:
        myGame.player.setMove(PlayerDir.up);
        if (myGame.player.getBlockY() < 14) {
          actionStep += 1;
        }
      default:
        endAction();
    }
  }
}
