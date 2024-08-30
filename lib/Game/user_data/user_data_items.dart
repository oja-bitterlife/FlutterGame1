import 'package:sqlite3/wasm.dart';
import '../../db.dart';

class UserDataItems {
  static const dbName = "user";
  static const tableName = "items";

  MemoryDB memoryDB;
  CommonDatabase userDB;
  UserDataItems(this.memoryDB, this.userDB);

  void reset() {
    userDB.execute("delete from $tableName");
  }

  bool? has(String name) {
    var result = memoryDB.select(
        "select used from $dbName.$tableName where and name = ?", [name]);
    if (result.isEmpty) return null;
    return result.first["used"];
  }

  void _setItem(String name, bool used) {
    memoryDB
        .execute("delete from $dbName.$tableName where and name = ?", [name]);
    memoryDB.execute("insert into $dbName.$tableName (name,used) values (?, ?)",
        [name, used]);
  }

  void obtain(String name) => _setItem(name, false);
  void use(String name) => _setItem(name, true);
}
