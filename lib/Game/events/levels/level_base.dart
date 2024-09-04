import 'package:my_app/Game/events/event_element.dart';
import 'package:my_app/Game/events/event_manager.dart';
import 'package:my_app/Game/my_game.dart';

// ignore: unused_import
import '../../../my_logger.dart';

import 'level0.dart';

abstract class LevelEventBase {
  MyGame get myGame => EventManager.myGame;
  LevelEventBase();

  void onEventStart(EventElement event) {
    log.info(
        "start_notice ${event.name}(${event.runtimeType}) => ${event.next?.name}(${event.next.runtimeType})");
  }

  void onEventFinish(EventElement event) {
    log.info(
        "finish_notice ${event.name}(${event.runtimeType}) => ${event.next?.name}(${event.next.runtimeType})");
  }
}

LevelEventBase? getLevelEvent(int level) {
  return switch (level) {
    0 => Level0(),
    _ => null,
  };
}
