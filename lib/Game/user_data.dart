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
            book_id INT(1),
            dir INT(1),
            blockX INT(3),
            blockY INT(3),
            time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )""",
      """CREATE TABLE IF NOT EXISTS items (
            book_id INT(1),
            name VARCHAR(255),
            used BOOLEAN
          )""",
      """CREATE TABLE IF NOT EXISTS map_event (
            book_id INT(1),
            name VARCHAR(255),
            blockX INT(3),
            blockY INT(3)
          )""",
      """CREATE TABLE IF NOT EXISTS movable (
            book_id INT(1),
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

  static Future<UserData> init(MyGame myGame) async {
    return UserData(myGame, await openUserDB(), await openUserTmp());
  }

  // 保持情報のクリア
  void reset() {
    userTmp.execute("delete from items where book_id = 1");
    userTmp.execute("delete from map_event where book_id = 1");
    userTmp.execute("delete from movable where book_id = 1");
  }

  bool get hasPlayerSave =>
      userDB.select("select time from player where book_id = 1").isNotEmpty;

  bool hasItem(String name, {bool checkUsed = true}) {
    var usedCheck = checkUsed ? "and used = 0" : "";
    return userTmp.select(
        "select used from items where book_id = 1 and name = ? $usedCheck",
        [name]).isNotEmpty;
  }

  void setItem(String name, {bool used = false}) {
    userTmp.execute("delete from items where book_id = 1 and name = ?", [name]);
    userTmp.execute(
        "insert into items (book_id,name,used) values (1, ?, ?)", [name, used]);
  }

  bool? isMobable(int blockX, int blockY) {
    var result = userTmp.select(
        "select movable from movable where book_id = 1 and blockX = ? and blockY = ?",
        [blockX, blockY]);
    if (result.isEmpty) return null;

    return result.first["movable"] != 0;
  }

  void setMovable(int blockX, int blockY, bool movable) {
    userTmp.execute(
        "delete from movable where book_id = 1 and blockX = ? and blockY = ?",
        [blockX, blockY]);
    userTmp.execute(
        "insert into movable (book_id,blockX,blockY,movable) values (1, ?, ?, ?)",
        [blockX, blockY, movable]);
  }

  String? getMapEvent(int blockX, int blockY) {
    var result = userTmp.select(
        "select name from map_event where book_id = 1 and blockX = ? and blockY = ?",
        [blockX, blockY]);
    if (result.isEmpty) return null;

    return result.first["name"];
  }

  void setMapEvent(String name, int blockX, int blockY) {
    userTmp.execute(
        "delete from map_event where book_id = 1 and blockX = ? and blockY = ?",
        [blockX, blockY]);
    userTmp.execute(
        "insert into map_event (book_id,name,blockX,blockY) values (1, ?, ?, ?)",
        [name, blockX, blockY]);
  }

  void save() {
    // プレイヤーデータを保存する
    userTmp.execute(
        "replace into player (book_id, dir, blockX, blockY) values (1, ?, ?, ?)",
        [
          myGame.player.dir.id,
          myGame.player.getBlockX(),
          myGame.player.getBlockY()
        ]);

    copyTable(userTmp, userDB, "player");
    copyTable(userTmp, userDB, "items");
    copyTable(userTmp, userDB, "map_event");
    copyTable(userTmp, userDB, "movable");
  }

  void load() {
    copyTable(userDB, userTmp, "player");
    copyTable(userDB, userTmp, "items");
    copyTable(userDB, userTmp, "map_event");
    copyTable(userDB, userTmp, "movable");

    // プレイヤーデータを読み込む
    var resultPlayerData = userTmp
        .select("select dir,blockX,blockY from player where book_id = 1");

    // まだセーブされていなかった
    if (resultPlayerData.isEmpty) {
      return;
    }

    // プレイヤーデータを更新
    var playerData = resultPlayerData.first;
    myGame.player.setDir(PlayerDir.values[playerData["dir"]]);
    myGame.player.position.x =
        PlayerComponent.getPosFromBlockX(playerData["blockX"]);
    myGame.player.position.y =
        PlayerComponent.getPosFromBlockY(playerData["blockY"]);
  }

  String getTime() {
    var result = userDB.select("select time from player");
    if (result.isEmpty) {
      return "----/--/-- --:--:--";
    }
    return result.first["time"];
  }
}
