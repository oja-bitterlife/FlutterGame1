import 'package:isar/isar.dart';

import 'package:my_app/my_logger.dart';

class DB {
  Id gameDataID = Isar.autoIncrement;
  Map<String, dynamic> gameData = {};

  void save() {
    log.info(gameData);
  }

  void load() {
    log.info(gameData);
  }
}
