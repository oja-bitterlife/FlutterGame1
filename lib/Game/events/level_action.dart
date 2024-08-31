import 'package:my_app/Game/player.dart';

import 'event_element.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class EventAction extends EventElement {
  String command;
  EventAction(super.name, this.command);

  @override
  void onStart() {
    gameRef.player.setMove(PlayerDir.up);
  }

  @override
  void onUpdate() {
    // 移動完了
    if (!gameRef.player.isMoving()) {
      finish();
    }
  }
}

class EventActionGroup extends EventQueue {
  EventActionGroup(super.name, String commands, [super.next]) {
    // データを確認して開始
    addAll(commands.split(",").map((command) => EventAction(name, command)));
  }
}
