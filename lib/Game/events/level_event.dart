import 'package:my_app/Game/my_game.dart';

// ignore: unused_import
import '../../my_logger.dart';

abstract class LevelEvent {
  MyGame myGame;
  late Map msgEventData;

  LevelEvent(this.myGame, this.msgEventData);

  void onFind(int blockX, int blockY);
  bool checkIdleEvent(int blockX, int blockY); // eventが起こればtrueを返す
}
