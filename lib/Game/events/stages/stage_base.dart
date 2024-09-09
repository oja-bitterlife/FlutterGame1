import '/Game/events/event_element.dart';
import '/Game/events/event_manager.dart';
import '/Game/my_game.dart';

// ignore: unused_import
import '../../../my_logger.dart';

import 'stage0.dart';
import 'stage1.dart';

abstract class StageEventBase {
  MyGame get myGame => EventManager.myGame;

  String stageTitle;
  StageEventBase(this.stageTitle);

  void onEventStart(EventElement event) {
    log.info(
        "start_notice ${event.name}(${event.runtimeType}) => ${event.next?.name}(${event.next.runtimeType})");
  }

  void onEventFinish(EventElement event) {
    log.info(
        "finish_notice ${event.name}(${event.runtimeType}) => ${event.next?.name}(${event.next.runtimeType})");
  }
}

StageEventBase? getStageEvent(int stage) {
  return switch (stage) {
    0 => Stage0(),
    1 => Stage1(),
    _ => null,
  };
}
