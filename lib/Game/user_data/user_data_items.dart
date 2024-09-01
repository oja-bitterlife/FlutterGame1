import '../../db.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class UserDataItems {
  static const tableName = "items";

  MemoryDB memoryDB;
  UserDataItems(this.memoryDB);

  bool isOwned(String name) {
    var result = memoryDB
        .select("SELECT used FROM user.$tableName WHERE name = ?", [name]);
    return result.isNotEmpty;
  }

  bool isUsed(String name) {
    var result = memoryDB
        .select("SELECT used FROM user.$tableName WHERE name = ?", [name]);
    if (result.isEmpty) return false;
    return result.first["used"] != 0;
  }

  void _setItem(String name, bool used) {
    memoryDB.execute("DELETE FROM user.$tableName WHERE name = ?", [name]);
    memoryDB.execute(
        "INSERT INTO user.$tableName (name,used) VALUES (?, ?)", [name, used]);
  }

  void obtain(String name) => _setItem(name, false);
  void use(String name) => _setItem(name, true);
}
