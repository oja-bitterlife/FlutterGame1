import 'package:sqlite3/wasm.dart';
import '../../db.dart';

class UserDataMapEvent {
  static const dbName = "user";
  static const tableName = "map_event";

  MemoryDB memoryDB;
  CommonDatabase userDB;
  UserDataMapEvent(this.memoryDB, this.userDB);

  void reset() {
    userDB.execute("delete from $tableName where book_id = 1");
  }

  String? get(int blockX, int blockY) {
    var result = memoryDB.select(
        "select name from $dbName.$tableName where book_id = 1 and blockX = ? and blockY = ?",
        [blockX, blockY]);
    if (result.isEmpty) return null;

    return result.first["name"];
  }

  void set(String name, int blockX, int blockY) {
    memoryDB.execute(
        "delete from $dbName.$tableName where book_id = 1 and blockX = ? and blockY = ?",
        [blockX, blockY]);
    memoryDB.execute(
        "insert into $dbName.$tableName (book_id,name,blockX,blockY) values (1, ?, ?, ?)",
        [name, blockX, blockY]);
  }
}
