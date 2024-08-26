import 'package:sqlite3/wasm.dart';
import '../../db.dart';
import '../my_game.dart';
import '../player.dart';

class UserDataPlayer {
  static const tableName = "user.player";

  MemoryDB memoryDB;
  CommonDatabase userDB;
  UserDataPlayer(this.memoryDB, this.userDB);

  void reset() {
    userDB.execute("delete from $tableName where book_id = 1");
  }

  void savePreProcess(MyGame myGame) {
    // プレイヤーデータを保存する
    myGame.memoryDB.execute("delete from $tableName where book_id = 1");
    myGame.memoryDB.execute(
        "insert into $tableName (book_id, dir, blockX, blockY) values (1, ?, ?, ?)",
        [
          myGame.player.dir.id,
          myGame.player.getBlockX(),
          myGame.player.getBlockY()
        ]);
  }

  void loadPostProcess(MyGame myGame) {
    // プレイヤーデータを読み込む
    var resultPlayerData = myGame.memoryDB
        .select("select dir,blockX,blockY from $tableName where book_id = 1");
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
