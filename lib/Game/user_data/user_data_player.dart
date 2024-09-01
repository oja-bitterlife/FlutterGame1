import '../../db.dart';
import '../my_game.dart';
import '../player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class UserDataPlayer {
  static const tableName = "player";

  MemoryDB memoryDB;
  UserDataPlayer(this.memoryDB);

  void savePreProcess(MyGame myGame) {
    // プレイヤーデータを保存する
    memoryDB.execute("DELETE FROM user.$tableName"); // 一旦削除
    memoryDB.execute(
        "INSERT INTO user.$tableName (dir, blockX, blockY) VALUES (?, ?, ?)", [
      myGame.player.dir.id,
      myGame.player.getBlockX(),
      myGame.player.getBlockY()
    ]);
  }

  void loadPostProcess(MyGame myGame) {
    // プレイヤーデータを読み込む
    var result =
        memoryDB.select("SELECT dir,blockX,blockY FROM user.$tableName");
    if (result.isEmpty) return; // まだセーブされていなかった

    // プレイヤーデータを更新
    var playerData = result.first;
    myGame.player.setDir(PlayerDir.values[playerData["dir"]]);
    myGame.player.position.x =
        PlayerComponent.getPosFromBlockX(playerData["blockX"]);
    myGame.player.position.y =
        PlayerComponent.getPosFromBlockY(playerData["blockY"]);
  }
}
