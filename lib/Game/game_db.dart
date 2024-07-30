import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_app/Game/my_game.dart';
import 'dart:convert';

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
    box.put('time', DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now()));

    box.put('playerDirID', playerDir.id);
    box.put('playerBlockX', playerBlockX);
    box.put('playerBlockY', playerBlockY);

    box.put('items', items);

    box.put("eventTiles", jsonEncode(eventTiles));
    box.put("moveTiles", jsonEncode(moveTiles));
  }

  void load() {
    playerDir = PlayerDir.fromID(box.get('playerDirID'));
    playerBlockX = box.get('playerBlockX');
    playerBlockY = box.get('playerBlockY');

    items = Map<String, int>.from(box.get('items'));

    eventTiles = List<dynamic>.from(jsonDecode(box.get("eventTiles")))
        .map((line) => List<int>.from(line))
        .toList();
    moveTiles = List<dynamic>.from(jsonDecode(box.get("moveTiles")))
        .map((line) => List<int>.from(line))
        .toList();
  }

  String getTime() {
    return box.get('time', defaultValue: "----/--/-- --:--:--");
  }
}
