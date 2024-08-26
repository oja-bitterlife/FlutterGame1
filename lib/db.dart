import 'package:flutter/services.dart';
import 'package:sqlite3/wasm.dart';

// ignore: unused_import
import '../my_logger.dart';

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

class MemoryDB {
  // SQLite3接続用
  final InMemoryFileSystem fileSystem;
  final WasmSqlite3 sqlite3;
  final CommonDatabase db;

  // コンストラクタで必要なDBを一気に読み込む
  MemoryDB(this.sqlite3, this.fileSystem, this.db) {
    loadDB("event", "assets/data/event.sqlite");
    loadDB("data", "assets/data/data.sqlite");
    loadDB("user", "assets/data/user.sqlite");
  }

  // wrapper
  ResultSet Function(String, [List<Object?>]) get select => db.select;
  void Function(String, [List<Object?>]) get execute => db.execute;
  CommonPreparedStatement Function(String) get prepare => db.prepare;

  // 初期化
  static Future<MemoryDB> create() async {
    var fileSystem = InMemoryFileSystem();
    final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
    sqlite3.registerVirtualFileSystem(fileSystem, makeDefault: true);
    var db = sqlite3.openInMemory();

    var self = MemoryDB(sqlite3, fileSystem, db);

    return self;
  }

  // DBのロード
  Future<void> loadDB(String dbName, String path) async {
    // assetからデータの読み込み
    ByteData data = await rootBundle.load(path);
    Uint8List bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // SQLite3のInMemoryFileSystemに書き込む
    var file = fileSystem
        .xOpen(Sqlite3Filename(fileSystem.xFullPathName(path)),
            SqlFlag.SQLITE_OPEN_READWRITE | SqlFlag.SQLITE_OPEN_CREATE)
        .file;
    file.xTruncate(0);
    file.xWrite(bytes, 0);
    file.xClose();

    // Attach Open
    db.execute("""attach database "$path" as $dbName""");
  }
}

// SaveLoad用テーブル内データ一括コピー
void copyTable(CommonDatabase src, CommonDatabase dist, String table) {
  dist.execute("delete from $table where book_id = 1");

  var result = src.select("select * from $table where book_id = 1");
  if (result.isEmpty) return;

  for (var data in result) {
    var keys = data.keys.join(",");
    var placeholders = List<String>.filled(data.length, "?").join(",");
    dist.execute(
        "insert into $table ($keys) values ($placeholders)", data.values);
  }
}
