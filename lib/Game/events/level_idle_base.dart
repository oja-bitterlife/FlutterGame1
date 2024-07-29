import '../my_game.dart';

abstract class LevelIdleBase {
  MyGame myGame;
  LevelIdleBase(this.myGame);

  void onIdle(int blockX, int blockY) {
    myGame.startIdle();
  }
}
