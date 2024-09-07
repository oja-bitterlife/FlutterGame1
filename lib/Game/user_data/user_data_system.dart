import '/Game/my_game.dart';
import '/main.dart';
import 'user_data.dart';

// ignore: unused_import
import '/my_logger.dart';

class UserDataSystem extends UserDataElement {
  UserDataSystem(super.memoryDB, super.dbName, super._tableName);

  @override
  Future<void> savePreProcess(MyGame myGame) async {
    memoryDB.execute("DELETE FROM $memoryTable");

    // サムネイルの保存
    var pngBytes = await MyGameWidget.screenshotController.capture();
    if (pngBytes != null) {
      memoryDB.execute("INSERT INTO $memoryTable (stage,image) VALUES (?,?)",
          [myGame.currentStage, pngBytes]);
    }
  }

  @override
  Future<void> loadPostProcess(MyGame myGame) async {
    // システムデータを読み込む
    var result = memoryDB.select("SELECT stage FROM $memoryTable");
    if (result.isEmpty) return; // まだセーブされていなかった

    myGame.currentStage = result.first["stage"];
  }
}
