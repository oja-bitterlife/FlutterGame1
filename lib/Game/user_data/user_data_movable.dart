import '../../db.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class UserDataMovable {
  static const tableName = "movable";

  MemoryDB memoryDB;
  UserDataMovable(this.memoryDB);

  bool? get(int blockX, int blockY) {
    var result = memoryDB.select(
        "SELECT movable FROM user.$tableName WHERE blockX = ? AND blockY = ?",
        [blockX, blockY]);
    if (result.isEmpty) return null;

    return result.first["movable"] != 0;
  }

  void set(int blockX, int blockY, bool movable) {
    memoryDB.execute(
        "DELETE FROM user.$tableName WHERE blockX = ? AND blockY = ?",
        [blockX, blockY]);
    memoryDB.execute(
        "INSERT INTO user.$tableName (blockX,blockY,movable) VALUES (?, ?, ?)",
        [blockX, blockY, movable]);
  }
}
