import '../../db.dart';
import '../my_game.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class UserDataMap {
  static const tableName = "map";

  MemoryDB memoryDB;
  UserDataMap(this.memoryDB);

  void savePreProcess(MyGame myGame) {
    memoryDB.execute("DELETE FROM user.$tableName");

    myGame.map.objs.getGidDiff().forEach((data) {
      memoryDB.execute(
          "INSERT INTO user.$tableName (type,gid,blockX,blockY) VALUES (?,?,?,?)",
          ["objs", data.gid, data.x, data.y]);
    });

    myGame.map.move.getGidDiff().forEach((data) {
      memoryDB.execute(
          "INSERT INTO user.$tableName (type,gid,blockX,blockY) VALUES (?,?,?,?)",
          ["move", data.gid, data.x, data.y]);
    });
  }

  void loadPostProcess(MyGame myGame) {}
}
