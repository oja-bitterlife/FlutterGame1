import '/Game/my_game.dart';
import '/Game/user_data/user_data.dart';

// ignore: unused_import
import '/my_logger.dart';

class UserDataMap extends UserDataElement {
  UserDataMap(super.memoryDB, super.dbName, super._tableName);

  @override
  Future<void> savePreProcess(MyGame myGame) async {
    memoryDB.execute("DELETE FROM $memoryTable");

    myGame.map.objs.getDiffList().forEach((data) {
      memoryDB.execute(
          "INSERT INTO $memoryTable (type,gid,blockX,blockY) VALUES (?,?,?,?)",
          ["objs", data.gid, data.x, data.y]);
    });

    myGame.map.move.getDiffList().forEach((data) {
      memoryDB.execute(
          "INSERT INTO $memoryTable (type,gid,blockX,blockY) VALUES (?,?,?,?)",
          ["move", data.gid, data.x, data.y]);
    });
  }

  @override
  Future<void> loadPostProcess(MyGame myGame) async {
    var result = memoryDB.select("SELECT * FROM $memoryTable");

    for (var data in result) {
      switch (data["type"]) {
        case "objs":
          myGame.map.objs.setDiff(data["gid"], data["blockX"], data["blockY"]);
        case "move":
          myGame.map.move.setDiff(data["gid"], data["blockX"], data["blockY"]);
      }
    }

    // 表示復活
    myGame.map.objs.updateSprites();
  }
}
