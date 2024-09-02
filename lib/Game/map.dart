import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled_utils/flame_tiled_utils.dart';

// ignore: unused_import
import '../my_logger.dart';

import 'priorities.dart';
import 'my_game.dart';

enum MapEventType {
  floor(0),
  wall(1),
  event(2),
  ;

  final int id;
  const MapEventType(this.id);
}

class TiledMap {
  MyGame myGame;
  late MapEvent event;
  late MapMove move;

  static const blockSize = 32;
  static late TiledComponent tiled;
  static late TiledAtlas atlas;

  static load(MyGame myGame) async {
    tiled = await TiledComponent.load("map.tmx", Vector2.all(16));
    atlas = await TiledAtlas.fromTiledMap(tiled.tileMap.map);
  }

  TiledMap(this.myGame) {
    var imageBatch = ImageBatchCompiler();

    // プレイヤの下に表示
    var underComponent = imageBatch
        .compileMapLayer(tileMap: tiled.tileMap, layerNames: ['UnderPlayer']);
    underComponent
      ..priority = Priority.mapUnder.index
      ..scale = Vector2.all(2);
    myGame.add(underComponent);

    // プレイヤの上に表示
    var overComponent = imageBatch
        .compileMapLayer(tileMap: tiled.tileMap, layerNames: ['OverPlayer']);
    overComponent
      ..priority = Priority.mapOver.index
      ..scale = Vector2.all(2);
    myGame.add(overComponent);

    // イベント用
    myGame.add(event = MapEvent(tiled, atlas.atlas!));
    myGame.add(move = MapMove(tiled));
  }

  MapEventType checkEventType(int blockX, int blockY) {
    // イベントチェック
    var eventGid = event.getProperty(blockX, blockY);
    if (eventGid != null) return MapEventType.event;

    // 移動不可チェック
    var movable = myGame.userData.movable.get(blockX, blockY);
    if (movable != null) {
      // ユーザーデータ優先
      return movable ? MapEventType.floor : MapEventType.wall;
    }
    var moveGid = move.tiles[blockY][blockX];
    if (moveGid != 0) return MapEventType.wall; // 移動不可

    // なにもない(床)
    return MapEventType.floor;
  }

  // 特殊なデータ取得用
  int getGid(String layerName, int blockX, int blockY) {
    // デバッグ用
    if (layerName == "UnderPlayerEvent" || layerName == "walk-flag") {
      log.warning("専用のクラス経由でアクセスしてください");
    }

    TileLayer? layer = tiled.tileMap.getLayer<TileLayer>(layerName);
    var gid = layer?.tileData?[blockY][blockX];
    return gid!.tile;
  }

  String? getProperty(String name, int gid, int blockX, int blockY) {
    if (gid == 0) return null;
    var prop = tiled.tileMap.map.tilesets[0].tiles[gid - 1].properties;
    return prop[name]?.value as String?;
  }
}

// マップイベント用オブジェクト
class MapEvent extends MapData {
  SpriteBatch sprites;

  MapEvent(TiledComponent tiled, Image image)
      : sprites = SpriteBatch(image),
        super(tiled, "UnderPlayerEvent") {
    add(SpriteBatchComponent(spriteBatch: sprites));
    updateSprites(); // 最初の更新
  }

  // 現在のタイルの状態で表示を更新
  void updateSprites() {
    sprites.clear();

    // Spriteの更新
    for (int y = 0; y < tiles.length; y++) {
      for (int x = 0; x < tiles[y].length; x++) {
        if (tiles[y][x] != 0) {
          int no = tiles[y][x] - 1;
          sprites.add(
              source: Rect.fromLTWH(no % 12 * 16, no ~/ 12 * 16, 16, 16),
              scale: 2.0,
              offset: Vector2(x * 32, y * 32));
        }
      }
    }
  }

  String? getProperty(int blockX, int blockY) =>
      _getProperty("event", blockX, blockY);
}

// 移動データ操作用
class MapMove extends MapData {
  MapMove(TiledComponent tiled) : super(tiled, "walk-flag");
}

// マップデータアクセスクラス
class MapData extends Component with HasGameRef<MyGame> {
  TiledComponent tiled;
  late List<List<int>> tiles;

  MapData(this.tiled, String layerName) {
    tiles = getOrgTiles(layerName);
  }

  List<List<int>> getOrgTiles(String layerName) {
    TileLayer? layer = tiled.tileMap.getLayer<TileLayer>(layerName);
    var tiles =
        List.generate(layer!.height, (i) => List.filled(layer.width, 0));

    for (int y = 0; y < layer.height; y++) {
      for (int x = 0; x < layer.width; x++) {
        var gid = layer.tileData?[y][x];
        tiles[y][x] = gid!.tile;
      }
    }
    return tiles;
  }

  String? _getProperty(String name, int blockX, int blockY) {
    int gid = tiles[blockY][blockX];
    if (gid == 0) return null;
    var prop = tiled.tileMap.map.tilesets[0].tiles[gid - 1].properties;
    return prop[name]?.value as String?;
  }
}
