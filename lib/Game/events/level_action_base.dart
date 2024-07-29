import 'package:my_app/Game/my_game.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

abstract class LevelActionBase {
  final MyGame myGame;
  String type = "";
  int actionStep = 0;

  LevelActionBase(this.myGame);

  bool get isPlaying {
    return type.isNotEmpty;
  }

  // アクションを開始する
  void start(String type) {
    this.type = type;
    actionStep = 0; // 最初から
    myGame.startIdle();
  }

  // アクションを強制終了して初期状態に
  void reset() {
    type = "";
  }

  void update();

  void onActionFinish(String type) {
    // idle開始
    myGame.eventManager
        .onIdle(myGame.player.getBlockX(), myGame.player.getBlockY());
  }
}
