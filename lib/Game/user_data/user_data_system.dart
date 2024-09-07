import 'package:my_app/main.dart';
import 'user_data.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class UserDataSystem extends UserDataElement {
  UserDataSystem(super.myGame, super.memoryDB, super.tableName);

  @override
  Future<void> savePreProcess() async {
    memoryDB.execute("DELETE FROM system.$tableName");

    // サムネイルの保存
    var pngBytes = await MyGameWidget.screenshotController.capture();
    if (pngBytes != null) {
      memoryDB.execute("INSERT INTO $tableName (image) VALUES (?)", [pngBytes]);
    }
  }

  @override
  Future<void> loadPostProcess() async {
    // システムデータを読み込む
    var result = memoryDB.select("SELECT stage FROM $tableName");
    if (result.isEmpty) return; // まだセーブされていなかった

    myGame.currentStage = result.first["stage"];
  }
}
