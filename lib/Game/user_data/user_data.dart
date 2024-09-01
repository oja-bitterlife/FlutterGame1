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
      // userDB.execute("""DROP TABLE IF EXISTS ${schema["name"]}""");
      userDB.execute((schema["sql"] as String)
          .replaceFirst("CREATE TABLE", "CREATE TABLE IF NOT EXISTS"));
    }

    // 各アクセス用クラス
    player = UserDataPlayer(memoryDB);
    items = UserDataItems(memoryDB);
    movable = UserDataMovable(memoryDB);
  }

  // 初期化
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
    memoryDB.execute("DELETE FROM user.${UserDataPlayer.tableName}");
    memoryDB.execute("DELETE FROM user.${UserDataItems.tableName}");
    memoryDB.execute("DELETE FROM user.${UserDataMovable.tableName}");
  }

  bool hasSave() {
    return userDB.select("SELECT time FROM player").isNotEmpty;
  }

  String getTime() {
    var result = userDB.select("SELECT time FROM player");
    if (result.isEmpty) {
      return "----/--/-- --:--:--";
    }
    return result.first["time"];
  }

  void save() {
    player.savePreProcess(myGame);

    copyTable(memoryDB.db, "user.${UserDataPlayer.tableName}", userDB,
        UserDataPlayer.tableName);
    copyTable(memoryDB.db, "user.${UserDataItems.tableName}", userDB,
        UserDataItems.tableName);
    copyTable(memoryDB.db, "user.${UserDataMovable.tableName}", userDB,
        UserDataMovable.tableName);
  }

  void load() {
    copyTable(userDB, UserDataPlayer.tableName, memoryDB.db,
        "user.${UserDataPlayer.tableName}");
    copyTable(userDB, UserDataItems.tableName, memoryDB.db,
        "user.${UserDataItems.tableName}");
    copyTable(userDB, UserDataMovable.tableName, memoryDB.db,
        "user.${UserDataMovable.tableName}");

    player.loadPostProcess(myGame);
  }
}
