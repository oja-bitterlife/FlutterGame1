import '../my_game.dart';
import 'event_element.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class EventAction extends EventElement {
  static const String actionEventTable = "event.action";

  int actionStep = 0;

  EventAction(MyGame myGame, String name) : super(myGame, "action", name) {
    // イベントメッセージ出力
    var result = myGame.memoryDB.select(
        "select * from $actionEventTable where level = ? and name = ?",
        [myGame.eventManager?.currentLevel, name]);

    // データを確認して開始
    if (result.isNotEmpty) {
      // next = EventInfo(result.first["next_type"], result.first["next_name"]);
    }
  }
}
