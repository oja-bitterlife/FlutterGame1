import '../../db.dart';
import '../my_game.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class UserDataMap {
  static const tableName = "map";

  MemoryDB memoryDB;
  UserDataMap(this.memoryDB);

  void savePreProcess(MyGame myGame) {
    memoryDB.execute("DELETE FROM user.map");
    myGame.map.objs.getGidList().forEach((data) {});
  }

  void loadPostProcess(MyGame myGame) {}
}
