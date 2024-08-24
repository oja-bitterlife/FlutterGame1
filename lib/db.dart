import 'package:flutter/services.dart';
import 'package:sqlite3/wasm.dart';

// SaveLoad用
Future<CommonDatabase> openUserDB() async {
  final fileSystem = await IndexedDbFileSystem.open(dbName: 'fluuter_game1');

  final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  sqlite3.registerVirtualFileSystem(fileSystem, makeDefault: true);
  var db = sqlite3.open("user.sqlite");

  // テーブル作成
  db.execute("""CREATE TABLE IF NOT EXISTS player (
            id INT(1) PRIMARY KEY,
            dir INT(1) DEFAULT 0,
            blockX INT(3) DEFAULT 0,
            blockY INT(3) DEFAULT 0,
            time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )""");

  db.execute("""CREATE TABLE IF NOT EXISTS items (
            player_id INT(1),
            name VARCHAR(255) NOT NULL,
            used BOOLEAN
          )""");

  // db.execute("""DROP TABLE IF EXISTS map_event""");
  db.execute("""CREATE TABLE IF NOT EXISTS map_event (
            player_id INT(1),
            name VARCHAR(255) NOT NULL,
            blockX INT(3),
            blockY INT(3)
          )""");

  return db;
}

// イベントデータ
Future<CommonDatabase> openEventDB() async {
  const path = "assets/data/event.sqlite";

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
