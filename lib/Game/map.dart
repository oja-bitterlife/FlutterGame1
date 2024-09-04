import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled_utils/flame_tiled_utils.dart';
import 'package:tiled/tiled.dart';

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
  late MapDiffObj objs;
  late MapDiffMove move;

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
    myGame.add(objs = MapDiffObj(tiled, atlas.atlas!));
    myGame.add(move = MapDiffMove(tiled));
  }

  MapEventType checkEventType(int blockX, int blockY) {
    // イベントチェック
    var eventGid =
        getProperty("event", getGid("UnderPlayerEvent", blockX, blockY));
    if (eventGid != null) return MapEventType.event;

    // 移動不可チェック
    var moveGid = getGid("walk-flag", blockX, blockY);
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
class MapDiffObj extends MapDiff {
  SpriteBatch sprites;
  late List<List<int>> overlay;

  MapDiffObj(TiledComponent tiled, Image image)
      : sprites = SpriteBatch(image),
        super(tiled, "UnderPlayerEvent") {
    // 表示用
    add(SpriteBatchComponent(spriteBatch: sprites));
    // 一時表示用
    overlay = List.generate(layer.height, (i) => List.filled(layer.width, 0));

    updateSprites(); // 最初の更新
  }

  void applyOverlay() {
    for (int y = 0; y < diffTiles.length; y++) {
      for (int x = 0; x < diffTiles[y].length; x++) {
        if (overlay[y][x] != 0) {
          diffTiles[y][x] = overlay[y][x];
          overlay[y][x] = 0;
        }
      }
    }
  }

  // 現在のタイルの状態で表示を更新
  void updateSprites() {
    sprites.clear();

    // Spriteの更新
    for (int y = 0; y < layer.height; y++) {
      for (int x = 0; x < layer.width; x++) {
        int gid = overlay[y][x] > 0 ? overlay[y][x] : getGid(x, y);
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
}

// 移動データ操作用
class MapDiffMove extends MapDiff {
  MapDiffMove(TiledComponent tiled) : super(tiled, "walk-flag");
}

// マップデータ変更管理クラス
class MapDiff extends Component {
  TileLayer layer;
  late List<List<int>> diffTiles;

  MapDiff(TiledComponent tiled, String layerName)
      : layer = tiled.tileMap.getLayer<TileLayer>(layerName)! {
    diffTiles = List.generate(layer.height, (i) => List.filled(layer.width, 0));
  }

  int getGid(int blockX, int blockY) {
    return diffTiles[blockY][blockX] != 0
        ? diffTiles[blockY][blockX]
        : layer.tileData?[blockY][blockX].tile ?? 0;
  }

  // 差分を拾う
  List<({int gid, int x, int y})> getGidDiff() {
    List<({int gid, int x, int y})> list = [];

    for (int y = 0; y < diffTiles.length; y++) {
      for (int x = 0; x < diffTiles[y].length; x++) {
        if (diffTiles[y][x] != 0) list.add((gid: diffTiles[y][x], x: x, y: y));
      }
    }

    return list;
  }
}
