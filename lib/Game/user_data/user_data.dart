import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../../db.dart';
import '../my_game.dart';

import 'user_data_player.dart';
import 'user_data_items.dart';
import 'user_data_map.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

// IndexedDBに保存するユーザーデータ
class UserData {
  late MyGame myGame;
  late MemoryDB memoryDB;
  late UserDB userDB;

  // 各アクセス用クラス
  late UserDataPlayer player;
  late UserDataItems items;
  late UserDataMap mapData;

  List<ImageProvider> thumbnails = [];

  UserData(this.myGame, this.userDB) : memoryDB = myGame.memoryDB {
    // memoryDBのユーザーデータテーブルをuserDBに移植する
    var schemas =
        memoryDB.select("SELECT * FROM user.sqlite_master WHERE type='table'");

    for (var schema in schemas) {
      // デバッグ用
      // userDB.execute("""DROP TABLE IF EXISTS ${schema["tbl_name"]}""");

      // テーブル作成
      userDB.execute((schema["sql"] as String)
          .replaceFirst("CREATE TABLE", "CREATE TABLE IF NOT EXISTS"));
    }

    // 各アクセス用クラス
    player = UserDataPlayer(memoryDB);
    items = UserDataItems(memoryDB);
    mapData = UserDataMap(memoryDB);
  }

  // 初期化
  static Future<UserData> init(MyGame myGame) async {
    var data = Uint8List(512 * 512 * 4);

    var c = Completer<ui.Image>();
    ui.decodeImageFromPixels(
        data, 512, 512, ui.PixelFormat.rgba8888, c.complete);
    var img = await c.future;

    ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    Uint8List bytes = byteData!.buffer.asUint8List();

    var self = UserData(myGame, await UserDB.create());
    for (var i = 0; i < 3; i++) {
      self.thumbnails.add(MemoryImage(bytes));
    }

    return self;
  }

  // 保持情報のクリア
  void reset() {
    memoryDB.execute("DELETE FROM user.${UserDataPlayer.tableName}");
    memoryDB.execute("DELETE FROM user.${UserDataItems.tableName}");
    memoryDB.execute("DELETE FROM user.${UserDataMap.tableName}");
  }

  bool hasSave(int book) {
    return userDB
        .select("SELECT time FROM player where book = ?", [book]).isNotEmpty;
  }

  String getTime(int book) {
    var result =
        userDB.select("SELECT time FROM player where book = ?", [book]);
    if (result.isEmpty) {
      return "----/--/-- --:--:--";
    }
    return result.first["time"];
  }

  int? getLevel(int book) {
    var result =
        userDB.select("SELECT level FROM player where book = ?", [book]);
    if (result.isEmpty) {
      return null;
    }
    return result.first["level"];
  }

  void save(int book) {
    player.savePreProcess(myGame);
    mapData.savePreProcess(myGame);

    copyTable(memoryDB, "user.${UserDataPlayer.tableName}", null, userDB,
        UserDataPlayer.tableName, book);
    copyTable(memoryDB, "user.${UserDataItems.tableName}", null, userDB,
        UserDataItems.tableName, book);
    copyTable(memoryDB, "user.${UserDataMap.tableName}", null, userDB,
        UserDataMap.tableName, book);

    debugPrintUserDB();
  }

  void load(int book) {
    copyTable(userDB, UserDataPlayer.tableName, book, memoryDB,
        "user.${UserDataPlayer.tableName}", null);
    copyTable(userDB, UserDataItems.tableName, book, memoryDB,
        "user.${UserDataItems.tableName}", null);
    copyTable(userDB, UserDataMap.tableName, book, memoryDB,
        "user.${UserDataMap.tableName}", null);

    player.loadPostProcess(myGame);
    mapData.loadPostProcess(myGame);

    debugPrintMemoryDB();
  }

  // DBの内容を表示する
  void _debugPrint(SQLiteDB db, String dbName, String option) {
    var resultPlayer =
        db.select("select * from $dbName${UserDataPlayer.tableName} $option");
    log.info("Player: $resultPlayer");
    var resultItems =
        db.select("select * from $dbName${UserDataItems.tableName} $option");
    log.info("Items: $resultItems");
    var resultMapData =
        db.select("select * from $dbName${UserDataMap.tableName} $option");
    log.info("Map: $resultMapData");
  }

  void debugPrintMemoryDB() {
    log.info("print DB: memoryDB");
    _debugPrint(memoryDB, "user.", "");
  }

  void debugPrintUserDB() {
    log.info("print DB: userDB");
    _debugPrint(userDB, "", "ORDER BY book");
  }
}
