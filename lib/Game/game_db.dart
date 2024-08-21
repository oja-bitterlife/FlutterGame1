import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_app/Game/my_game.dart';
import 'dart:convert';

import 'player.dart';

import 'package:sqlite3/wasm.dart';

import 'package:flutter/services.dart';

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

Future<CommonDatabase> openUserDB() async {
  final fileSystem = await IndexedDbFileSystem.open(dbName: 'fluuter_game1');

  final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  sqlite3.registerVirtualFileSystem(fileSystem, makeDefault: true);
  var db = sqlite3.open("user_data.sqlite");

  db.execute("""CREATE TABLE IF NOT EXISTS user (
          Dir INT(1) NOT NULL,
          BlockX INT(3) NOT NULL,
          BlockY INT(3) NOT NULL,
          items TEXT NULL
        )""");

  return db;
}

Future<CommonDatabase> openEventDB(String path) async {
  // assetからデータの読み込み
  ByteData data = await rootBundle.load(path);
  Uint8List bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

  // SQLite3のInMemoryFileSystemに書き込む
  var fileSystem = InMemoryFileSystem();
  var file = fileSystem
      .xOpen(Sqlite3Filename(fileSystem.xFullPathName(path)),
          SqlFlag.SQLITE_OPEN_READWRITE | SqlFlag.SQLITE_OPEN_CREATE)
      .file;
  file.xTruncate(0);
  file.xWrite(bytes, 0);
  file.xClose();

  // SQLite3で開く
  final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  sqlite3.registerVirtualFileSystem(fileSystem, makeDefault: true);
  return sqlite3.open(path);
}
