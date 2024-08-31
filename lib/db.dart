import 'package:flutter/services.dart';
import 'package:sqlite3/wasm.dart';

// ignore: unused_import
import '../my_logger.dart';

// 統括データベース
class MemoryDB {
  // SQLite3接続用
  final InMemoryFileSystem fileSystem;
  final WasmSqlite3 sqlite3;
  final CommonDatabase db;

  MemoryDB(this.sqlite3, this.fileSystem, this.db);

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

    // 初期データ読み込み
    await self.loadDB("event", "assets/data/event.sqlite");
    await self.loadDB("data", "assets/data/data.sqlite");
    await self.loadDB("user", "assets/data/user.sqlite");

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
void copyTable(CommonDatabase src, String srcTable, CommonDatabase dist,
    String distTable) {
  dist.execute("delete from $distTable where book_id = 1");

  var result = src.select("select * from $srcTable where book_id = 1");
  if (result.isEmpty) return;

  for (var data in result) {
    var keys = data.keys.join(",");
    var placeholders = List<String>.filled(data.length, "?").join(",");
    dist.execute(
        "insert into $distTable ($keys) values ($placeholders)", data.values);
  }
}
