import 'package:sqlite3/wasm.dart';

import '../db.dart';
import 'my_game.dart';
import 'player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

// IndexedDBに保存するユーザーデータ
class UserData {
  // 使用テーブル
  static const playerTable = "user.player";
  static const itemsTable = "user.items";
  static const mapEventTable = "user.map_event";
  static const movableTable = "user.movable";

  late MyGame myGame;
  CommonDatabase userDB;

  UserData(this.myGame, this.userDB) {
    var schemas = myGame.memoryDB
        .select("SELECT * FROM user.sqlite_master WHERE type='table'");
    for (var schema in schemas) {
      // userDB.execute("""DROP TABLE IF EXISTS ${schema["name"]}""");
      userDB.execute((schema["sql"] as String)
          .replaceFirst("CREATE TABLE", "CREATE TABLE IF NOT EXISTS"));
    }
  }

  static Future<UserData> init(MyGame myGame) async {
    // IndexedDB上にDBを作成する
    final fileSystem = await IndexedDbFileSystem.open(dbName: 'fluuter_game1');
    final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
    sqlite3.registerVirtualFileSystem(fileSystem, makeDefault: true);
    var db = sqlite3.open("user.sqlite");

    return UserData(myGame, db);
  }

  // 保持情報のクリア
  void reset() {
    myGame.memoryDB.execute("delete from $playerTable where book_id = 1");
    myGame.memoryDB.execute("delete from $itemsTable where book_id = 1");
    myGame.memoryDB.execute("delete from $mapEventTable where book_id = 1");
    myGame.memoryDB.execute("delete from $movableTable where book_id = 1");
  }

  bool get hasPlayerSave =>
      userDB.select("select time from player where book_id = 1").isNotEmpty;

  bool hasItem(String name, {bool checkUsed = true}) {
    var usedCheck = checkUsed ? "and used = 0" : "";
    return myGame.memoryDB.select(
        "select used from $itemsTable where book_id = 1 and name = ? $usedCheck",
        [name]).isNotEmpty;
  }

  void setItem(String name, {bool used = false}) {
    myGame.memoryDB.execute(
        "delete from $itemsTable where book_id = 1 and name = ?", [name]);
    myGame.memoryDB.execute(
        "insert into $itemsTable (book_id,name,used) values (1, ?, ?)",
        [name, used]);
  }

  bool? isMobable(int blockX, int blockY) {
    var result = myGame.memoryDB.select(
        "select movable from $movableTable where book_id = 1 and blockX = ? and blockY = ?",
        [blockX, blockY]);
    if (result.isEmpty) return null;

    return result.first["movable"] != 0;
  }

  void setMovable(int blockX, int blockY, bool movable) {
    myGame.memoryDB.execute(
        "delete from $movableTable where book_id = 1 and blockX = ? and blockY = ?",
        [blockX, blockY]);
    myGame.memoryDB.execute(
        "insert into $movableTable (book_id,blockX,blockY,movable) values (1, ?, ?, ?)",
        [blockX, blockY, movable]);
  }

  String? getMapEvent(int blockX, int blockY) {
    var result = myGame.memoryDB.select(
        "select name from $mapEventTable where book_id = 1 and blockX = ? and blockY = ?",
        [blockX, blockY]);
    if (result.isEmpty) return null;

    return result.first["name"];
  }

  void setMapEvent(String name, int blockX, int blockY) {
    myGame.memoryDB.execute(
        "delete from $mapEventTable where book_id = 1 and blockX = ? and blockY = ?",
        [blockX, blockY]);
    myGame.memoryDB.execute(
        "insert into $mapEventTable (book_id,name,blockX,blockY) values (1, ?, ?, ?)",
        [name, blockX, blockY]);
  }

  void save() {
    // プレイヤーデータを保存する
    myGame.memoryDB.execute("delete from $playerTable where book_id = 1");
    myGame.memoryDB.execute(
        "insert into $playerTable (book_id, dir, blockX, blockY) values (1, ?, ?, ?)",
        [
          myGame.player.dir.id,
          myGame.player.getBlockX(),
          myGame.player.getBlockY()
        ]);

    copyTable(myGame.memoryDB.db, playerTable, userDB, "player");
    copyTable(myGame.memoryDB.db, itemsTable, userDB, "items");
    copyTable(myGame.memoryDB.db, mapEventTable, userDB, "map_event");
    copyTable(myGame.memoryDB.db, movableTable, userDB, "movable");
  }

  void load() {
    copyTable(userDB, "player", myGame.memoryDB.db, playerTable);
    copyTable(userDB, "items", myGame.memoryDB.db, itemsTable);
    copyTable(userDB, "map_event", myGame.memoryDB.db, mapEventTable);
    copyTable(userDB, "movable", myGame.memoryDB.db, movableTable);

    // プレイヤーデータを読み込む
    var resultPlayerData = myGame.memoryDB
        .select("select dir,blockX,blockY from $playerTable where book_id = 1");
    if (resultPlayerData.isEmpty) return; // まだセーブされていなかった

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
