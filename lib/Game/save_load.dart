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
  Map<String, bool> items = {}; // <name, used>
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

  bool get hasData => userDB.select("select time from player").isNotEmpty;

  void save() {
    // プレイヤーデータを保存する
    userDB.execute(
        "replace into player (id, dir, blockX, blockY) values (1, ?, ?, ?)", [
      myGame.player.dir.id,
      myGame.player.getBlockX(),
      myGame.player.getBlockY()
    ]);

    // アイテムを保存する
    userDB.execute("delete from items where player_id = 1"); // 一旦空に
    var prepared = userDB
        .prepare("insert into items (player_id, name, used) values (1, ?, ?)");
    // 個々に保存
    for (var name in items.keys) {
      prepared.execute([name, items[name]]);
    }
  }

  void load() {
    // プレイヤーデータを読み込む
    var resultPlayerData =
        userDB.select("select dir,blockX,blockY from player where id = 1");

    // まだセーブされていなかった
    if (resultPlayerData.isEmpty) {
      return;
    }

    var playerData = resultPlayerData.first;
    myGame.player.setDir(PlayerDir.values[playerData["dir"] as int]);
    myGame.player.position.x =
        PlayerComponent.getPosFromBlockX(playerData["blockX"]);
    myGame.player.position.y =
        PlayerComponent.getPosFromBlockY(playerData["blockY"]);

    // アイテムを読み込む
    var resultItemData =
        userDB.select("select name,used from items where player_id = 1");
    items.clear();
    for (var itemData in resultItemData) {
      items[itemData["name"]] = itemData["used"] != 0;
    }
    log.info(items);
  }

  String getTime() {
    var result = userDB.select("select time from player");
    if (result.isEmpty) {
      return "----/--/-- --:--:--";
    }
    return result.first["time"];
  }
}
