import 'package:flutter/material.dart';
import '../../db.dart';
import '../my_game.dart';

import 'user_data_system.dart';
import 'user_data_player.dart';
import 'user_data_items.dart';
import 'user_data_map.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

// IndexedDBに保存するユーザーデータ
class UserDataManager {
  late MyGame myGame;

  // 主にDBを扱う
  late MemoryDB memoryDB;
  late UserDB storageDB;

  // 各アクセス用クラス
  Map<String, UserDataElement> manageData = {};
  UserDataSystem get system => manageData["system"] as UserDataSystem;
  UserDataPlayer get player => manageData["player"] as UserDataPlayer;
  UserDataMap get mapData => manageData["map"] as UserDataMap;
  UserDataItems get items => manageData["items"] as UserDataItems;

  UserDataManager(this.myGame, this.storageDB, bool withDBDrop)
      : memoryDB = myGame.memoryDB {
    // memoryDBのユーザーデータテーブルをuserDBに移植する
    var schemas =
        memoryDB.select("SELECT * FROM user.sqlite_master WHERE type='table'");

    for (var schema in schemas) {
      // デバッグ用
      if (withDBDrop) {
        storageDB.execute("""DROP TABLE IF EXISTS ${schema["tbl_name"]}""");
      }

      // テーブル作成
      storageDB.execute((schema["sql"] as String)
          .replaceFirst("CREATE TABLE", "CREATE TABLE IF NOT EXISTS"));
    }

    // 各アクセス用クラスの作成
    manageData = {
      "system": UserDataSystem(myGame, memoryDB, "user", "system"),
      "player": UserDataPlayer(myGame, memoryDB, "user", "player"),
      "items": UserDataItems(myGame, memoryDB, "user", "items"),
      "map": UserDataMap(myGame, memoryDB, "user", "map"),
    };
  }

  // 初期化
  static Future<UserDataManager> init(MyGame myGame,
      {required bool withDBDrop}) async {
    return UserDataManager(myGame, await UserDB.create(), withDBDrop);
  }

  // 保持情報のクリア
  void reset() {
    for (var element in manageData.values) {
      memoryDB.execute("DELETE FROM ${element.memoryTable}");
    }
  }

// セーブデータのシステム情報を取得する
  ({String? time, int stage, ImageProvider? image})? getSavedStageData(
      int book, bool needImage) {
    // imageは重いので引数指定で不要なときは取得しない
    String items = "time,stage";
    items += needImage ? ",image" : "";

    // システムデータ取得
    var result =
        storageDB.select("SELECT $items FROM system where book = ?", [book]);
    if (result.isEmpty) return null;

    // イメージが必要な時は組み立て
    ImageProvider? img;
    if (needImage && result.first["image"] != null) {
      img = MemoryImage(result.first["image"]);
    }

    return (
      time: result.first["time"],
      stage: result.first["stage"],
      image: img,
    );
  }

  // セーブ
  Future<void> save(int book) async {
    for (var element in manageData.values) {
      // セーブ前の情報回収
      await element.savePreProcess();

      // セーブ
      copyTable(memoryDB, element.memoryTable, null, storageDB,
          element.storageTable, book);

      debugPrintStorageDB(element.storageTable);
    }
  }

  // ロード
  Future<void> load(int book) async {
    for (var element in manageData.values) {
      // ロード
      copyTable(storageDB, element.storageTable, book, memoryDB,
          element.memoryTable, null);

      // ロードしたデータを適用する
      await element.loadPostProcess();

      debugPrintMemoryDB(element.memoryTable);
    }
  }

  // DBの内容を表示する(デバッグ用)
  void _debugPrint(SQLiteDB db, String tableName, String option) {
    var result = db.select("select * from $tableName $option");

    // imageは邪魔なので表示しない
    var data = result.map((row) =>
        row.map((key, value) => MapEntry(key, key == "image" ? [] : value)));

    log.info("$tableName: $data");
  }

  void debugPrintMemoryDB(String tableName) {
    log.info("print DB: memoryDB");
    _debugPrint(memoryDB, tableName, "");
  }

  void debugPrintStorageDB(String tableName) {
    log.info("print DB: storageDB");
    _debugPrint(storageDB, tableName, "ORDER BY book");
  }
}

class UserDataElement {
  final MyGame myGame;
  final MemoryDB memoryDB;
  final String dbName, _tableName;

  UserDataElement(this.myGame, this.memoryDB, this.dbName, this._tableName);

  String get memoryTable => "$dbName.$_tableName";
  String get storageTable => _tableName;

  Future<void> savePreProcess() async {}
  Future<void> loadPostProcess() async {}
}
