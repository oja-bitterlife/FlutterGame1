import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_tiled_utils/flame_tiled_utils.dart';

// ignore: unused_import
import '../my_logger.dart';
import 'priorities.dart';
import 'my_game.dart';
import 'game_db.dart';

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

  static int blockSize = 32;
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
    var event = getEvent(blockX, blockY);
    if (event != null) return MapEventType.event;

    // 移動不可チェック
    if (myGame.db.moveTiles[blockY][blockX] != 0) {
      return MapEventType.wall; // 移動不可
    }

    return MapEventType.floor; // なにもない(床)
  }

  // イベントチェック
  String? getEvent(int blockX, int blockY) {
    // イベントタイルが存在した
    int no = myGame.db.eventTiles[blockY][blockX];
    if (no != 0) {
      // タイル情報のeventを読む
      String? s = tiled.tileMap.map.tileByGid(no)?.properties["event"]?.value
          as String?;

      if (s != null) return s;
    }

    // イベントは存在しなかった
    return null;
  }

  // タイルマップの状態を変更する
  void changeEvent(int blockX, int blockY, int no) {
    myGame.db.eventTiles[blockY][blockX] = no + 1;
  }

  void changeMove(int blockX, int blockY, bool isMovable) {
    myGame.db.moveTiles[blockY][blockX] = isMovable ? 0 : 1;
  }

  // イベントタイル表示
  void updateEventComponent() {
    eventSprites.clear();

    // Spriteの更新
    for (int y = 0; y < myGame.db.eventTiles.length; y++) {
      for (int x = 0; x < myGame.db.eventTiles[y].length; x++) {
        int no = myGame.db.eventTiles[y][x] - 1;
        if (myGame.db.eventTiles[y][x] != 0) {
          eventSprites.add(
              source: Rect.fromLTWH(no % 12 * 16, no ~/ 12 * 16, 16, 16),
              scale: 2.0,
              offset: Vector2(x * 32, y * 32));
        }
      }
    }
  }

  // オリジナルのeventリストを返す
  static List<List<int>> getEventTiles() {
    TileLayer? layer = tiled.tileMap.getLayer<TileLayer>("UnderPlayerEvent");
    var eventTiles =
        List.generate(layer!.height, (i) => List.filled(layer.width, 0));

    for (int y = 0; y < layer.height; y++) {
      for (int x = 0; x < layer.width; x++) {
        var gid = layer.tileData?[y][x];
        eventTiles[y][x] = gid!.tile;
      }
    }
    return eventTiles;
  }

  // オリジナルのmoveリストを返す
  static List<List<int>> getMoveTiles() {
    TileLayer? layer = tiled.tileMap.getLayer<TileLayer>("walk-flag");
    var moveTiles =
        List.generate(layer!.height, (i) => List.filled(layer.width, 0));

    for (int y = 0; y < layer.height; y++) {
      for (int x = 0; x < layer.width; x++) {
        var gid = layer.tileData?[y][x];
        moveTiles[y][x] = gid!.tile;
      }
    }
    return moveTiles;
  }
}
