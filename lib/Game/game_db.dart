import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_app/Game/my_game.dart';

import 'player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class GameDB {
  late MyGame myGame;
  static late Box box;

  GameDB(this.myGame);

  // 管理対象データ
  PlayerDir playerDir = PlayerDir.down;
  int playerBlockX = 7, playerBlockY = 14;
  Map<String, int> items = {};

  static Future<GameDB> init(MyGame myGame) async {
    await Hive.initFlutter();
    box = await Hive.openBox('GameDB');

    return GameDB(myGame);
  }

  void save() {
    box.put('playerDirID', playerDir.id);
    box.put('playerBlockX', playerBlockX);
    box.put('playerBlockY', playerBlockY);
    box.put('items', items);
    box.put('time', DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now()));
  }

  void load() {
    playerDir = PlayerDir.fromID(box.get('playerDirID'));
    playerBlockX = box.get('playerBlockX');
    playerBlockY = box.get('playerBlockY');
  }

  String getTime() {
    return box.get('time', defaultValue: "----/--/-- --:--:--");
  }
}
