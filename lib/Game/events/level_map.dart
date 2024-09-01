import '../my_game.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

// itemの状態によってマップイベントを変更する
String changeMapEvent(MyGame myGame, String name) {
  var results = myGame.memoryDB.select(
      "SELECT * FROM event.map WHERE name = ? ORDER BY priority DESC", [name]);

  for (var result in results) {
    // アイテム保有時
    if (result["own"] != null) {
      if (myGame.userData.items.isOwned(result["own"])) {
        return result["next"];
      }
    }

    // アイテム使用時
    if (result["used"] != null) {
      if (myGame.userData.items.isUsed(result["used"])) {
        return result["next"];
      }
    }
  }

  return name;
}
