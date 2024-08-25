import 'package:flutter/services.dart';
import 'package:sqlite3/wasm.dart';

// 実行時ユーザーデータ
Future<CommonDatabase> openUserTmp() async {
  final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  sqlite3.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
  return sqlite3.openInMemory();
}

// SaveLoad用
Future<CommonDatabase> openUserDB() async {
  final fileSystem = await IndexedDbFileSystem.open(dbName: 'fluuter_game1');

  final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  sqlite3.registerVirtualFileSystem(fileSystem, makeDefault: true);
  return sqlite3.open("user.sqlite");
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
