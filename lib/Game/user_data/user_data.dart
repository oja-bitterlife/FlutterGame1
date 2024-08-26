import 'package:my_app/Game/user_data/user_data_movable.dart';
import 'package:sqlite3/wasm.dart';

import '../../db.dart';
import '../my_game.dart';
import '../player.dart';

import 'user_data_items.dart';
import 'user_data_map_event.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

// IndexedDBに保存するユーザーデータ
class UserData {
  // 使用テーブル
  static const playerTable = "user.player";

  late MyGame myGame;
  CommonDatabase userDB;

  late UserDataItems items;
  late UserDataMapEvent mapEvent;
  late UserDataMovable movable;

  UserData(this.myGame, this.userDB) {
    var schemas = myGame.memoryDB
        .select("SELECT * FROM user.sqlite_master WHERE type='table'");
    for (var schema in schemas) {
      // userDB.execute("""DROP TABLE IF EXISTS ${schema["name"]}""");
      userDB.execute((schema["sql"] as String)
          .replaceFirst("CREATE TABLE", "CREATE TABLE IF NOT EXISTS"));
    }

    // 各アクセス用クラス
    items = UserDataItems(myGame.memoryDB, userDB);
    mapEvent = UserDataMapEvent(myGame.memoryDB, userDB);
    movable = UserDataMovable(myGame.memoryDB, userDB);
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
    items.reset();
    mapEvent.reset();
    movable.reset();
  }

  bool get hasPlayerSave =>
      userDB.select("select time from player where book_id = 1").isNotEmpty;

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
    copyTable(myGame.memoryDB.db, UserDataItems.tableName, userDB, "items");
    copyTable(
        myGame.memoryDB.db, UserDataMapEvent.tableName, userDB, "map_event");
    copyTable(myGame.memoryDB.db, UserDataMovable.tableName, userDB, "movable");
  }

  void load() {
    copyTable(userDB, "player", myGame.memoryDB.db, playerTable);
    copyTable(userDB, "items", myGame.memoryDB.db, UserDataItems.tableName);
    copyTable(
        userDB, "map_event", myGame.memoryDB.db, UserDataMapEvent.tableName);
    copyTable(userDB, "movable", myGame.memoryDB.db, UserDataMovable.tableName);

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
