import 'package:sqlite3/wasm.dart';

import '../../db.dart';
import '../my_game.dart';

import 'user_data_player.dart';
import 'user_data_items.dart';
import 'user_data_movable.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

// IndexedDBに保存するユーザーデータ
class UserData {
  static const currentVersion = "v1";

  late MyGame myGame;
  late MemoryDB memoryDB;
  CommonDatabase userDB;

  // 各アクセス用クラス
  late UserDataPlayer player;
  late UserDataItems items;
  late UserDataMovable movable;

  UserData(this.myGame, this.userDB) : memoryDB = myGame.memoryDB {
    // memoryDBのユーザーデータテーブルをuserDBに移植する
    var schemas =
        memoryDB.select("SELECT * FROM user.sqlite_master WHERE type='table'");
    for (var schema in schemas) {
      userDB.execute("""DROP TABLE IF EXISTS ${schema["tbl_name"]}""");
      userDB.execute((schema["sql"] as String)
          .replaceFirst("CREATE TABLE", "CREATE TABLE IF NOT EXISTS"));

      userDB
          .execute("ALTER TABLE ${schema["tbl_name"]} ADD book INTEGER FIRST");
    }

    // 各アクセス用クラス
    player = UserDataPlayer(memoryDB);
    items = UserDataItems(memoryDB);
    movable = UserDataMovable(memoryDB);
  }

  // 初期化
  static Future<UserData> init(MyGame myGame) async {
    // IndexedDB上にDBを作成する
    final fileSystem =
        await IndexedDbFileSystem.open(dbName: 'fluuter_game1_$currentVersion');
    final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
    sqlite3.registerVirtualFileSystem(fileSystem, makeDefault: true);
    var db = sqlite3.open("user.sqlite");

    return UserData(myGame, db);
  }

  // 保持情報のクリア
  void reset() {
    memoryDB.execute("DELETE FROM user.${UserDataPlayer.tableName}");
    memoryDB.execute("DELETE FROM user.${UserDataItems.tableName}");
    memoryDB.execute("DELETE FROM user.${UserDataMovable.tableName}");
  }

  bool hasSave(int book) {
    return userDB
        .select("SELECT time FROM player where book = ?", [book]).isNotEmpty;
  }

  String getTime(int book) {
    var result =
        userDB.select("SELECT time FROM player where book = ?", [book]);
    if (result.isEmpty) {
      return "----/--/-- --:--:--";
    }
    return result.first["time"];
  }

  void save(int book) {
    player.savePreProcess(myGame);

    copyTable(memoryDB.db, "user.${UserDataPlayer.tableName}", null, userDB,
        UserDataPlayer.tableName, book);
    copyTable(memoryDB.db, "user.${UserDataItems.tableName}", null, userDB,
        UserDataItems.tableName, book);
    copyTable(memoryDB.db, "user.${UserDataMovable.tableName}", null, userDB,
        UserDataMovable.tableName, book);

    debugPrintUserDB();
  }

  void load(int book) {
    copyTable(userDB, UserDataPlayer.tableName, book, memoryDB.db,
        "user.${UserDataPlayer.tableName}", null);
    copyTable(userDB, UserDataItems.tableName, book, memoryDB.db,
        "user.${UserDataItems.tableName}", null);
    copyTable(userDB, UserDataMovable.tableName, book, memoryDB.db,
        "user.${UserDataMovable.tableName}", null);

    player.loadPostProcess(myGame);
    debugPrintMemoryDB();
  }

  void _debugPrint(CommonDatabase db) {
    var resultPlayer = db.select("select * from ${UserDataPlayer.tableName}");
    resultPlayer.forEach(log.info);
    var resultItems = db.select("select * from ${UserDataItems.tableName}");
    resultItems.forEach(log.info);
    var resultMovable = db.select("select * from ${UserDataMovable.tableName}");
    resultMovable.forEach(log.info);
  }

  void debugPrintMemoryDB() => _debugPrint(memoryDB.db);
  void debugPrintUserDB() => _debugPrint(userDB);
}
