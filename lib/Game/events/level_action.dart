import 'package:my_app/Game/player.dart';

import '../my_game.dart';
import 'event_element.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class EventAction extends EventElement {
  String command;
  EventAction(MyGame myGame, String name, this.command)
      : super(myGame, "action", name);

  @override
  void onStart() {
    myGame.player.setMove(PlayerDir.up);
  }

  @override
  void onUpdate() {
    // 移動完了
    if (!myGame.player.isMoving()) {
      finish();
    }
  }
}

class EventActionGroup extends EventQueue {
  static const String actionEventTable = "event.action";

  EventActionGroup.fromDB(MyGame myGame, String name)
      : super(myGame, "action", name) {
    // イベントメッセージ出力
    var result = myGame.memoryDB.select(
        "select * from $actionEventTable where level = ? and name = ?",
        [myGame.eventManager.currentLevel, name]);

    // データを確認して開始
    if (result.isNotEmpty) {
      addAll((result.first["action"] as String)
          .split(",")
          .map((command) => EventAction(myGame, name, command)));
      next = (type: result.first["next_type"], name: result.first["next_name"]);
    }
  }

  @override
  void onUpdate() {
    log.info(children.length);

    if (!hasChildren) {
      finish();
    }
  }
}
