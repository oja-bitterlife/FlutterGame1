import '../my_game.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

abstract class LevelMovedBase {
  final MyGame myGame;
  final int level; // ステージ番号

  LevelMovedBase(this.myGame, this.level);

  void onMoveFinish(int blockX, int blockY) {
    log.info("finish move: $blockX, $blockY");

    // 移動が終わったらコマンド待ち
    myGame.startIdle();
  }
}
