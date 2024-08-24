import 'package:sqlite3/common.dart';

import '../db.dart';
import 'my_game.dart';
import 'player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class SaveLoad {
  late MyGame myGame;
  CommonDatabase userDB;

  SaveLoad(this.myGame, this.userDB);

  // 管理対象データ
  // PlayerDir playerDir = PlayerDir.down;
  // int playerBlockX = 7, playerBlockY = 14;

  Map<String, int> items = {};
  late List<List<int>> eventTiles, moveTiles;

  static Future<SaveLoad> init(MyGame myGame, List<List<int>> orgEventTiles,
      List<List<int>> orgMoveTiles) async {
    var self = SaveLoad(myGame, await openUserDB());
    self.reset(orgEventTiles, orgMoveTiles);

    return self;
  }

  void reset(List<List<int>> orgEventTiles, List<List<int>> orgMoveTiles) {
    eventTiles = orgEventTiles.map((e) => e.toList()).toList();
    moveTiles = orgMoveTiles.map((e) => e.toList()).toList();
  }

  void save() {}

  void load() {}

  String getTime() {
    var result = userDB.select("select time from user");
    log.info(result);
    if (result.isEmpty) {
      return "----/--/-- --:--:--";
    }
    return result.first["time"];
  }
}
