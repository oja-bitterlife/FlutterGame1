import 'package:my_app/Game/events/event_element.dart';
import 'package:my_app/Game/my_game.dart';

import 'level0.dart';

abstract class LevelEventBase {
  MyGame myGame;
  LevelEventBase(this.myGame);

  void onEventFinish(EventElement event);
}

LevelEventBase? getLevelEvent(MyGame myGame, int level) {
  return switch (level) {
    0 => Level0(myGame),
    _ => null,
  };
}
