import 'package:sqlite3/wasm.dart';
import '../../db.dart';

class UserDataItems {
  static const tableName = "user.items";

  MemoryDB memoryDB;
  CommonDatabase userDB;
  UserDataItems(this.memoryDB, this.userDB);

  void reset() {
    userDB.execute("delete from $tableName where book_id = 1");
  }

  bool? has(String name) {
    var result = memoryDB.select(
        "select used from $tableName where book_id = 1 and name = ?", [name]);
    if (result.isEmpty) return null;
    return result.first["used"];
  }

  void _setItem(String name, bool used) {
    memoryDB.execute(
        "delete from $tableName where book_id = 1 and name = ?", [name]);
    memoryDB.execute(
        "insert into $tableName (book_id,name,used) values (1, ?, ?)",
        [name, used]);
  }

  void obtain(String name) => _setItem(name, false);
  void use(String name) => _setItem(name, true);
}
