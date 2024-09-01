import 'package:sqlite3/wasm.dart';
import '../../db.dart';

class UserDataItems {
  static const dbName = "user";
  static const tableName = "items";

  MemoryDB memoryDB;
  CommonDatabase userDB;
  UserDataItems(this.memoryDB, this.userDB);

  void reset() {
    userDB.execute("DELETE FROM $tableName");
  }

  bool has(String name) {
    var result = memoryDB
        .select("SELECT used FROM $dbName.$tableName WHERE name = ?", [name]);
    return result.isNotEmpty;
  }

  bool used(String name) {
    var result = memoryDB
        .select("SELECT used FROM $dbName.$tableName WHERE name = ?", [name]);
    if (result.isEmpty) return false;
    return result.first["used"] != 0;
  }

  void _setItem(String name, bool used) {
    memoryDB.execute("DELETE FROM $dbName.$tableName WHERE name = ?", [name]);
    memoryDB.execute("INSERT INTO $dbName.$tableName (name,used) VALUES (?, ?)",
        [name, used]);
  }

  void obtain(String name) => _setItem(name, false);
  void use(String name) => _setItem(name, true);
}
