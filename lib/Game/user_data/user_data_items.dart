import '/Game/user_data/user_data.dart';

// ignore: unused_import
import '/my_logger.dart';

class UserDataItems extends UserDataElement {
  UserDataItems(super.memoryDB, super.dbName, super._tableName);

  bool isOwned(String name) {
    var result =
        memoryDB.select("SELECT used FROM $memoryTable WHERE name = ?", [name]);
    return result.isNotEmpty;
  }

  bool isUsed(String name) {
    var result = memoryDB.select(
        "SELECT used FROM $memoryTable WHERE name = ? and used != 0", [name]);
    return result.isNotEmpty;
  }

  void _setItem(String name, bool used) {
    memoryDB.execute("DELETE FROM $memoryTable WHERE name = ?", [name]);
    memoryDB.execute(
        "INSERT INTO $memoryTable (name,used) VALUES (?, ?)", [name, used]);
  }

  void obtain(String name) => _setItem(name, false);
  void use(String name) => _setItem(name, true);
}
