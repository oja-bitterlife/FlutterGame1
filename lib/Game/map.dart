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
  late MapObj objs;
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
    myGame.add(objs = MapObj(tiled, atlas.atlas!));
    myGame.add(move = MapMove(tiled));
  }

  MapEventType checkEventType(int blockX, int blockY) {
    // イベントチェック
    var eventGid =
        getProperty("event", getGid("UnderPlayerEvent", blockX, blockY));
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
    TileLayer? layer = tiled.tileMap.getLayer<TileLayer>(layerName);
    var gid = layer?.tileData?[blockY][blockX];
    return gid!.tile;
  }

  String? getProperty(String name, int gid) {
    if (gid == 0) return null;
    var prop = tiled.tileMap.map.tilesets[0].tiles[gid - 1].properties;
    return prop[name]?.value as String?;
  }

  String? getEventProperty(int blockX, blockY) =>
      getProperty("event", getGid("UnderPlayerEvent", blockX, blockY));
}

// マップイベント用オブジェクト
class MapObj extends MapData {
  SpriteBatch sprites;
  late List<List<int>> overlay;

  MapObj(TiledComponent tiled, Image image)
      : sprites = SpriteBatch(image),
        super(tiled, "UnderPlayerEvent") {
    // 表示用
    add(SpriteBatchComponent(spriteBatch: sprites));
    // 一時表示用
    overlay =
        tiles.map((element) => List<int>.filled(element.length, 0)).toList();

    updateSprites(); // 最初の更新
  }

  void applyOverlay() {
    for (int y = 0; y < tiles.length; y++) {
      for (int x = 0; x < tiles[y].length; x++) {
        if (overlay[y][x] != 0) {
          tiles[y][x] = overlay[y][x];
          overlay[y][x] = 0;
        }
      }
    }
  }

  // 現在のタイルの状態で表示を更新
  void updateSprites() {
    sprites.clear();

    // Spriteの更新
    for (int y = 0; y < tiles.length; y++) {
      for (int x = 0; x < tiles[y].length; x++) {
        int gid = overlay[y][x] > 0 ? overlay[y][x] : tiles[y][x];
        if (gid != 0) {
          sprites.add(
              source: Rect.fromLTWH(
                  (gid - 1) % 12 * 16, (gid - 1) ~/ 12 * 16, 16, 16),
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
