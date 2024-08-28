import 'package:my_app/Game/events/event_manager.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class EventAction extends EventElement {
  static const String actionEventTable = "event.action";

  int actionStep = 0;

  EventAction(super.name) {
    // イベントメッセージ出力
    var result = myGame.memoryDB.select(
        "select * from $actionEventTable where level = ? and name = ?",
        [myGame.eventManager.currentLevel, name]);

    // データを確認して開始
    if (result.isNotEmpty) {
      next = EventNext(result.first["next_type"], result.first["next_name"]);
    }
  }

  @override
  void update() {
    finish();
  }
}
