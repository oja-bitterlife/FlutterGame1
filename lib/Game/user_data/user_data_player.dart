import 'package:sqlite3/wasm.dart';
import '../../db.dart';
import '../my_game.dart';
import '../player.dart';

class UserDataPlayer {
  static const dbName = "user";
  static const tableName = "player";

  MemoryDB memoryDB;
  CommonDatabase userDB;
  UserDataPlayer(this.memoryDB, this.userDB);

  void reset() {
    userDB.execute("delete from $tableName");
  }

  void savePreProcess(MyGame myGame) {
    // プレイヤーデータを保存する
    memoryDB.execute("delete from $dbName.$tableName");
    memoryDB.execute(
        "insert into $tableName (dir, blockX, blockY) values (?, ?, ?)", [
      myGame.player.dir.id,
      myGame.player.getBlockX(),
      myGame.player.getBlockY()
    ]);
  }

  void loadPostProcess(MyGame myGame) {
    // プレイヤーデータを読み込む
    var resultPlayerData =
        memoryDB.select("select dir,blockX,blockY from $dbName.$tableName");
    if (resultPlayerData.isEmpty) return; // まだセーブされていなかった

    // プレイヤーデータを更新
    var playerData = resultPlayerData.first;
    myGame.player.setDir(PlayerDir.values[playerData["dir"]]);
    myGame.player.position.x =
        PlayerComponent.getPosFromBlockX(playerData["blockX"]);
    myGame.player.position.y =
        PlayerComponent.getPosFromBlockY(playerData["blockY"]);
  }
}
