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

  static const blockSize = 32;
  static late TiledComponent tiled;
  static late TiledAtlas atlas;

  late SpriteBatch eventSprites;

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

    // プレイヤの上に表示
    var overComponent = imageBatch
        .compileMapLayer(tileMap: tiled.tileMap, layerNames: ['OverPlayer']);
    overComponent
      ..priority = Priority.mapOver.index
      ..scale = Vector2.all(2);

    myGame.add(underComponent);
    myGame.add(overComponent);

    // イベント表示追加
    eventSprites = SpriteBatch(atlas.atlas!);
    myGame.add(PositionComponent(
        children: [SpriteBatchComponent(spriteBatch: eventSprites)],
        priority: Priority.mapUnder.index));
    updateEventComponent();
  }

  MapEventType checkEventType(int blockX, int blockY) {
    // イベントチェック
    var event = myGame.eventManager?.getMapEvent(blockX, blockY);
    if (event != null) return MapEventType.event;

    // 移動不可チェック
    var movable = myGame.userData.movable.get(blockX, blockY);
    if (movable != null) {
      // ユーザーデータ優先
      return movable ? MapEventType.floor : MapEventType.wall;
    }
    var moveGid = getMoveGid(blockX, blockY);
    if (moveGid != 0) return MapEventType.wall; // 移動不可

    // なにもない(床)
    return MapEventType.floor;
  }

  // イベントタイル表示
  void updateEventComponent() {
    eventSprites.clear();

    // Spriteの更新
    // for (int y = 0; y < myGame.userData.viewTiles.length; y++) {
    //   for (int x = 0; x < myGame.userData.viewTiles[y].length; x++) {
    //     int no = myGame.userData.viewTiles[y][x] - 1;
    //     if (myGame.userData.viewTiles[y][x] != 0) {
    //       eventSprites.add(
    //           source: Rect.fromLTWH(no % 12 * 16, no ~/ 12 * 16, 16, 16),
    //           scale: 2.0,
    //           offset: Vector2(x * 32, y * 32));
    //     }
    //   }
    // }
  }

  // List<List<int>> getOrgTiles(String layerName) {
  //   TileLayer? layer = tiled.tileMap.getLayer<TileLayer>(layerName);
  //   var tiles =
  //       List.generate(layer!.height, (i) => List.filled(layer.width, 0));

  //   for (int y = 0; y < layer.height; y++) {
  //     for (int x = 0; x < layer.width; x++) {
  //       var gid = layer.tileData?[y][x];
  //       tiles[y][x] = gid!.tile;
  //     }
  //   }
  //   return tiles;
  // }

  int getGid(String layerName, int blockX, int blockY) {
    TileLayer? layer = tiled.tileMap.getLayer<TileLayer>(layerName);
    var gid = layer?.tileData?[blockY][blockX];
    return gid!.tile;
  }

  int getEventGid(int blockX, int blockY) {
    return getGid("UnderPlayerEvent", blockX, blockY);
  }

  int getMoveGid(int blockX, int blockY) {
    return getGid("walk-flag", blockX, blockY);
  }

  String? getTilesetProperty(int gid, String propName) {
    if (gid == 0) return null;
    var prop = tiled.tileMap.map.tilesets[0].tiles[gid - 1].properties;
    return prop["event"]?.value as String?;
  }
}
