import 'package:my_app/Game/player.dart';

import '../my_game.dart';
import 'event_element.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class EventAction extends EventElement {
  String command;
  EventAction(String name, this.command) : super("action", name);

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
  static const String actionEventTable = "event.action";

  EventActionGroup.fromDB(MyGame myGame, String name) : super("action", name) {
    // イベントメッセージ出力
    var result = myGame.memoryDB.select(
        "select * from $actionEventTable where level = ? and name = ?",
        [myGame.eventManager.currentLevel, name]);

    // データを確認して開始
    if (result.isNotEmpty) {
      addAll((result.first["action"] as String)
          .split(",")
          .map((command) => EventAction(name, command)));
      next = (type: result.first["next_type"], name: result.first["next_name"]);
    }
  }
}
