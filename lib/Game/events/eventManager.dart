import '../my_game.dart';
import 'level_event.dart';

import 'level1.dart';

// ignore: unused_import
import '../../my_logger.dart';

class Eventmanager {
  late MyGame myGame;

  late LevelEvent event;

  Eventmanager(this.myGame);

  static Future<Eventmanager> create(MyGame myGame) async {
    var self = Eventmanager(myGame);

    // とりあえずLevel1を作っていく
    self.event = await Level1.create(myGame);

    return self;
  }

  Future<void> reload() async {}

  // Findアイコンが押された(イベントオブジェクトがある)
  void onFind(int blockX, int blockY) {
    String? type = myGame.map.getEvent(blockX, blockY);
    if (type != null) {
      event.onFind(type, blockX, blockY);
    }
  }

  // 移動完了時イベント
  void onMoved(int blockX, int blockY) {
    event.onMoved(blockX, blockY);
  }

  // メッセージ表示終わりコールバック
  void onMessageFinish(String type) {
    event.onMessageFinish(type);
  }
}
