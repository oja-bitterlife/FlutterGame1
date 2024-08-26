import 'package:sqlite3/wasm.dart';
import '../../db.dart';

class UserDataMovable {
  static const dbName = "user";
  static const tableName = "movable";

  MemoryDB memoryDB;
  CommonDatabase userDB;
  UserDataMovable(this.memoryDB, this.userDB);

  void reset() {
    userDB.execute("delete from $tableName where book_id = 1");
  }

  bool? get(int blockX, int blockY) {
    var result = memoryDB.select(
        "select movable from $dbName.$tableName where book_id = 1 and blockX = ? and blockY = ?",
        [blockX, blockY]);
    if (result.isEmpty) return null;

    return result.first["movable"] != 0;
  }

  void set(int blockX, int blockY, bool movable) {
    memoryDB.execute(
        "delete from $dbName.$tableName where book_id = 1 and blockX = ? and blockY = ?",
        [blockX, blockY]);
    memoryDB.execute(
        "insert into $dbName.$tableName (book_id,blockX,blockY,movable) values (1, ?, ?, ?)",
        [blockX, blockY, movable]);
  }
}
