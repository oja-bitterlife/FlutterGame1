import 'package:flutter/services.dart';
import 'package:sqlite3/wasm.dart';

// ignore: unused_import
import '../my_logger.dart';

class SQLiteDB {
  // SQLite3接続用
  final WasmSqlite3 sqlite3;
  final CommonDatabase db;

  SQLiteDB(this.sqlite3, this.db);

  // wrapper
  ResultSet Function(String, [List<Object?>]) get select => db.select;
  void Function(String, [List<Object?>]) get execute => db.execute;
  CommonPreparedStatement Function(String) get prepare => db.prepare;
}

// 統括データベース
class MemoryDB extends SQLiteDB {
  MemoryDB._(super.sqlite3, super.db);

  // 初期化
  static Future<MemoryDB> create() async {
    var fileSystem = InMemoryFileSystem();
    var sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
    sqlite3.registerVirtualFileSystem(fileSystem, makeDefault: true);
    var db = sqlite3.openInMemory();

    var self = MemoryDB._(sqlite3, db);

    // 初期データ読み込み
    await self._loadDB(fileSystem, "event", "assets/data/event.sqlite");
    await self._loadDB(fileSystem, "data", "assets/data/data.sqlite");
    await self._loadDB(fileSystem, "user", "assets/data/user.sqlite");

    return self;
  }

  // DBのロード
  Future<void> _loadDB(
      InMemoryFileSystem fileSystem, String dbName, String path) async {
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

class UserDB extends SQLiteDB {
  static const currentVersion = "v1";

  UserDB._(super.sqlite3, super.db);

  // 初期化
  static Future<UserDB> create() async {
    // IndexedDB上にDBを作成する
    var fileSystem =
        await IndexedDbFileSystem.open(dbName: 'fluuter_game1_$currentVersion');
    var sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
    sqlite3.registerVirtualFileSystem(fileSystem, makeDefault: true);
    var db = sqlite3.open("user.sqlite");

    var self = UserDB._(sqlite3, db);
    return self;
  }
}

// SaveLoad用テーブル内データ一括コピー
void copyTable(SQLiteDB src, String srcTable, int? srcBook, SQLiteDB dist,
    String distTable, int? distBook) {
  // book対応
  var srcWhere = srcBook != null ? "where book = ?" : "";
  var srcParams = srcBook != null ? [srcBook] : [];
  var distWhere = distBook != null ? "where book = ?" : "";
  var distParams = distBook != null ? [distBook] : [];

  // srcからデータを拾う
  var result = src.select("SELECT * FROM $srcTable $srcWhere", srcParams);

  // distは削除して全部入れ替える
  dist.execute("DELETE FROM $distTable $distWhere", distParams);

  // データコピー
  for (var data in result) {
    // 扱いやすいよう一旦Dictに
    Map<String, dynamic> params = {
      for (var entry in data.entries) entry.key: entry.value
    };

    // book対応
    if (distBook != null) params["book"] = distBook;

    // 削除済みなので単純なinsertでいい
    var columns = params.keys.join(",");
    var placeholders = List<String>.filled(params.length, "?").join(",");
    dist.execute("INSERT INTO $distTable ($columns) VALUES ($placeholders)",
        params.values.toList());
  }
}
