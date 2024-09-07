import 'package:my_app/Game/my_game.dart';
import 'package:my_app/Game/user_data/user_data.dart';

import '../player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class UserDataPlayer extends UserDataElement {
  UserDataPlayer(super.memoryDB, super.dbName, super._tableName);

  @override
  Future<void> savePreProcess(MyGame myGame) async {
    // プレイヤーデータを保存する
    memoryDB.execute("DELETE FROM $memoryTable"); // 一旦削除
    memoryDB.execute(
        "INSERT INTO $memoryTable (dir, blockX, blockY) VALUES (?, ?, ?)", [
      myGame.player.dir.id,
      myGame.player.getBlockX(),
      myGame.player.getBlockY()
    ]);
  }

  @override
  Future<void> loadPostProcess(MyGame myGame) async {
    // プレイヤーデータを読み込む
    var result = memoryDB.select("SELECT dir,blockX,blockY FROM $memoryTable");
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
