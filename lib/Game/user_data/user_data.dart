import 'package:my_app/Game/user_data/user_data_movable.dart';
import 'package:sqlite3/wasm.dart';

import '../../db.dart';
import '../my_game.dart';

import 'user_data_player.dart';
import 'user_data_items.dart';
import 'user_data_map_event.dart';
import 'user_data_movable.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

// IndexedDBに保存するユーザーデータ
class UserData {
  // 使用テーブル
  static const playerTable = "user.player";

  late MyGame myGame;
  CommonDatabase userDB;

  // 各アクセス用クラス
  late UserDataPlayer player;
  late UserDataItems items;
  late UserDataMapEvent mapEvent;
  late UserDataMovable movable;

  UserData(this.myGame, this.userDB) {
    // memoryDBのユーザーデータテーブルをuserDBに移植する
    var schemas = myGame.memoryDB
        .select("SELECT * FROM user.sqlite_master WHERE type='table'");
    for (var schema in schemas) {
      // userDB.execute("""DROP TABLE IF EXISTS ${schema["name"]}""");
      userDB.execute((schema["sql"] as String)
          .replaceFirst("CREATE TABLE", "CREATE TABLE IF NOT EXISTS"));
    }

    // 各アクセス用クラス
    player = UserDataPlayer(myGame.memoryDB, userDB);
    items = UserDataItems(myGame.memoryDB, userDB);
    mapEvent = UserDataMapEvent(myGame.memoryDB, userDB);
    movable = UserDataMovable(myGame.memoryDB, userDB);
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
    mapEvent.reset();
    movable.reset();
  }

  bool hasSave() {
    return userDB
        .select("select time from player where book_id = 1")
        .isNotEmpty;
  }

  String getTime() {
    var result = userDB.select("select time from player where book_id = 1");
    if (result.isEmpty) {
      return "----/--/-- --:--:--";
    }
    return result.first["time"];
  }

  void save() {
    player.savePreProcess(myGame);

    copyTable(myGame.memoryDB.db, UserDataPlayer.tableName, userDB, "player");
    copyTable(myGame.memoryDB.db, UserDataItems.tableName, userDB, "items");
    copyTable(
        myGame.memoryDB.db, UserDataMapEvent.tableName, userDB, "map_event");
    copyTable(myGame.memoryDB.db, UserDataMovable.tableName, userDB, "movable");
  }

  void load() {
    copyTable(userDB, "player", myGame.memoryDB.db, UserDataPlayer.tableName);
    copyTable(userDB, "items", myGame.memoryDB.db, UserDataItems.tableName);
    copyTable(
        userDB, "map_event", myGame.memoryDB.db, UserDataMapEvent.tableName);
    copyTable(userDB, "movable", myGame.memoryDB.db, UserDataMovable.tableName);

    player.loadPostProcess(myGame);
  }
}
