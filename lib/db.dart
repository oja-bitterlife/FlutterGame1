import 'package:flutter/services.dart';
import 'package:sqlite3/wasm.dart';

// SaveLoad用
Future<CommonDatabase> openUserDB() async {
  final fileSystem = await IndexedDbFileSystem.open(dbName: 'fluuter_game1');

  final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  sqlite3.registerVirtualFileSystem(fileSystem, makeDefault: true);
  var db = sqlite3.open("user.sqlite");

  // テーブル作成
  db.execute("""CREATE TABLE IF NOT EXISTS user (
            Dir INT(1) NOT NULL,
            BlockX INT(3) NOT NULL,
            BlockY INT(3) NOT NULL,
            items TEXT NULL,
            time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
