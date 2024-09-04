import 'package:my_app/db.dart';
import '../my_game.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class UserDataMap {
  static const tableName = "map";

  MemoryDB memoryDB;
  UserDataMap(this.memoryDB);

  void savePreProcess(MyGame myGame) {
    memoryDB.execute("DELETE FROM user.$tableName");

    myGame.map.objs.getDiffList().forEach((data) {
      memoryDB.execute(
          "INSERT INTO user.$tableName (type,gid,blockX,blockY) VALUES (?,?,?,?)",
          ["objs", data.gid, data.x, data.y]);
    });

    myGame.map.move.getDiffList().forEach((data) {
      memoryDB.execute(
          "INSERT INTO user.$tableName (type,gid,blockX,blockY) VALUES (?,?,?,?)",
          ["move", data.gid, data.x, data.y]);
    });
  }

  void loadPostProcess(MyGame myGame) {
    var result = memoryDB.select("SELECT * FROM user.$tableName");

    for (var data in result) {
      log.info(data);
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
