import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class GameDB {
  static late Box box;

  // 管理対象データ
  PlayerDir playerDir = PlayerDir.down;
  int playerBlockX = 7, playerBlockY = 14;

  static Future<GameDB> init() async {
    await Hive.initFlutter();
    box = await Hive.openBox('GameDB');

    return GameDB();
  }

  void save() {
    box.put('playerDirID', playerDir.id);
    box.put('playerBlockX', playerBlockX);
    box.put('playerBlockY', playerBlockY);
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
