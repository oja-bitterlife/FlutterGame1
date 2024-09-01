import 'package:sqlite3/wasm.dart';
import '../../db.dart';

class UserDataMovable {
  static const dbName = "user";
  static const tableName = "movable";

  MemoryDB memoryDB;
  CommonDatabase userDB;
  UserDataMovable(this.memoryDB, this.userDB);

  void reset() {
    userDB.execute("DELETE FROM $tableName");
  }

  bool? get(int blockX, int blockY) {
    var result = memoryDB.select(
        "SELECT movable FROM $dbName.$tableName WHERE blockX = ? AND blockY = ?",
        [blockX, blockY]);
    if (result.isEmpty) return null;

    return result.first["movable"] != 0;
  }

  void set(int blockX, int blockY, bool movable) {
    memoryDB.execute(
        "DELETE FROM $dbName.$tableName WHERE blockX = ? AND blockY = ?",
        [blockX, blockY]);
    memoryDB.execute(
        "INSERT INTO $dbName.$tableName (blockX,blockY,movable) VALUES (?, ?, ?)",
        [blockX, blockY, movable]);
  }
}
