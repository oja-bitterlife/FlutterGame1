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
    player = UserDataPlayer(memoryDB, userDB);
    items = UserDataItems(memoryDB, userDB);
    movable = UserDataMovable(memoryDB, userDB);
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
    player.reset();
    items.reset();
    movable.reset();
  }

  bool hasSave() {
    return userDB.select("select time from player").isNotEmpty;
  }

  String getTime() {
    var result = userDB.select("select time from player where");
    if (result.isEmpty) {
      return "----/--/-- --:--:--";
    }
    return result.first["time"];
  }

  void save() {
    player.savePreProcess(myGame);

    copyTable(memoryDB.db, UserDataPlayer.tableName, userDB, "player");
    copyTable(memoryDB.db, UserDataItems.tableName, userDB, "items");
    copyTable(memoryDB.db, UserDataMovable.tableName, userDB, "movable");
  }

  void load() {
    copyTable(userDB, "player", memoryDB.db, UserDataPlayer.tableName);
    copyTable(userDB, "items", memoryDB.db, UserDataItems.tableName);
    copyTable(userDB, "movable", memoryDB.db, UserDataMovable.tableName);

    player.loadPostProcess(myGame);
  }
}
