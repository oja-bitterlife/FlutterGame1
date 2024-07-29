import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_app/Game/map.dart';
import 'package:my_app/Game/my_game.dart';

import 'player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class GameDB {
  late MyGame myGame;
  static late Box box;

  GameDB(this.myGame, this.eventTiles, this.moveTiles);

  // 管理対象データ
  PlayerDir playerDir = PlayerDir.down;
  int playerBlockX = 7, playerBlockY = 14;
  Map<String, int> items = {};
  List<List<int>> eventTiles, moveTiles;

  static Future<void> init(MyGame myGame) async {
    await Hive.initFlutter();
    box = await Hive.openBox('GameDB');
  }

  void save() {
    box.put('playerDirID', playerDir.id);
    box.put('playerBlockX', playerBlockX);
    box.put('playerBlockY', playerBlockY);
    box.put('items', items);
    box.put('time', DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now()));

    box.put("eventTiles", eventTiles);
    box.put("moveTiles", moveTiles);
  }

  void load() {
    playerDir = PlayerDir.fromID(box.get('playerDirID'));
    playerBlockX = box.get('playerBlockX');
    playerBlockY = box.get('playerBlockY');
    items = Map<String, int>.from(box.get('items'));

    eventTiles = List<List<int>>.from(box.get("eventTiles"));
    moveTiles = List<List<int>>.from(box.get("moveTiles"));
  }

  String getTime() {
    return box.get('time', defaultValue: "----/--/-- --:--:--");
  }
}
