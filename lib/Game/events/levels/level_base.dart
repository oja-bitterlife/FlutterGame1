import 'package:my_app/Game/events/event_element.dart';
import 'package:my_app/Game/events/event_manager.dart';
import 'package:my_app/Game/my_game.dart';

import 'level0.dart';

abstract class LevelEventBase {
  MyGame get myGame => EventManager.myGame;
  LevelEventBase();

  void onEventStart(EventElement event);
  void onEventFinish(EventElement event);
}

LevelEventBase? getLevelEvent(int level) {
  return switch (level) {
    0 => Level0(),
    _ => null,
  };
}
