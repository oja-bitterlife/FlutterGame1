import 'package:flame/game.dart';
import 'package:sqlite3/common.dart';

import '../db.dart';
import 'my_game.dart';
import 'player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class UserData {
  late MyGame myGame;
  CommonDatabase userDB, userTmp;

  UserData(this.myGame, this.userDB, this.userTmp) {
    // userTmp.select("select * from movable");

    // テーブル作成
    var tables = [
      """CREATE TABLE IF NOT EXISTS player (
            id INT(1) PRIMARY KEY,
            dir INT(1) DEFAULT 0,
            blockX INT(3) DEFAULT 0,
            blockY INT(3) DEFAULT 0,
            time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )""",
      """CREATE TABLE IF NOT EXISTS items (
            player_id INT(1),
            name VARCHAR(255),
            used BOOLEAN
          )""",
      """CREATE TABLE IF NOT EXISTS map_event (
            player_id INT(1),
            name VARCHAR(255),
            blockX INT(3),
            blockY INT(3)
          )""",
      """CREATE TABLE IF NOT EXISTS movable (
            player_id INT(1),
            blockX INT(3),
            blockY INT(3),
            movable INT(1)
          )"""
    ];

    for (var sql in tables) {
      userDB.execute(sql);
      userTmp.execute(sql);
    }
  }

  // 管理対象データ
  Map<String, bool> items = {}; // <name, used>
  Map<String, Vector2> mapEvents = {}; // <name, blockPos>
  Map<Vector2, bool> movables = {}; // <blockPos, movable>

  static Future<UserData> init(MyGame myGame) async {
    return UserData(myGame, await openUserDB(), await openUserTmp());
  }

  // 保持情報のクリア
  void reset() {
    items.clear();
    mapEvents.clear();
    movables.clear();
  }

  bool get hasPlayerSave => userDB.select("select time from player").isNotEmpty;

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
    var preparedItems = userDB
        .prepare("insert into items (player_id, name, used) values (1, ?, ?)");
    // 個々に保存
    items.forEach((itemName, isUsed) {
      preparedItems.execute([itemName, isUsed]);
    });

    // MAP上書きイベントの保存
    userDB.execute("delete from map_event where player_id = 1"); // 一旦空に
    var preparedMapEvent = userDB.prepare(
        "insert into map_event (player_id, name, blockX, blockY) values (1, ?, ?, ?)");
    mapEvents.forEach((eventName, block) {
      preparedMapEvent.execute([eventName, block.x, block.y]);
    });

    // 移動上書きの保存
    userDB.execute("delete from movable where player_id = 1"); // 一旦空に
    var preparedMovable = userDB.prepare(
        "insert into movable (player_id, blockX, blockY, movable) values (1, ?, ?, ?)");
    movables.forEach((block, movable) {
      preparedMovable.execute([
        block.x,
        block.y,
        movable,
      ]);
    });
  }

  void load() {
    // プレイヤーデータを読み込む
    var resultPlayerData =
        userDB.select("select dir,blockX,blockY from player where id = 1");

    // まだセーブされていなかった
    if (resultPlayerData.isEmpty) {
      return;
    }

    // プレイヤーデータを更新
    var playerData = resultPlayerData.first;
    myGame.player.setDir(PlayerDir.values[playerData["dir"] as int]);
    myGame.player.position.x =
        PlayerComponent.getPosFromBlockX(playerData["blockX"]);
    myGame.player.position.y =
        PlayerComponent.getPosFromBlockY(playerData["blockY"]);

    // アイテムを読み込む
    var resultItems =
        userDB.select("select name,used from items where player_id = 1");
    items.clear();
    for (var item in resultItems) {
      items[item["name"]] = item["used"] != 0;
    }

    // MAPイベントを読み込む
    var resultMapEvent = userDB
        .select("select name,blockX,blockY from map_event where player_id = 1");
    mapEvents.clear();
    for (var mapEvent in resultMapEvent) {
      mapEvents[mapEvent["name"]] =
          Vector2(mapEvent["blockX"], mapEvent["blockY"]);
    }

    // 移動上書きを読み込む
    var resultMovable = userDB.select(
        "select blockX,blockY,movable from movable where player_id = 1");
    movables.clear();
    for (var movable in resultMovable) {
      movables[Vector2(movable["blockX"], movable["blockY"])] =
          movable["movable"] != 0;
    }
  }

  String getTime() {
    var result = userDB.select("select time from player");
    if (result.isEmpty) {
      return "----/--/-- --:--:--";
    }
    return result.first["time"];
  }
}
