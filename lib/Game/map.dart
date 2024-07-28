import 'package:flame/components.dart';
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

enum EventTile {
  sensorUp(448),
  sensorDown(461),
  letter(509),
  treasure(373),
  treasureOpen(374),
  bedside(715),
  ;

  final int id;
  const EventTile(this.id);
}

class TiledManager {
  MyGame myGame;

  static int blockSize = 32;
  late TiledComponent tiled;

  // 表示コンポーネント
  late final PositionComponent underComponent;
  late final PositionComponent overComponent;
  late PositionComponent eventComponent;

  TiledManager(this.myGame);

  static Future<TiledManager> create(MyGame myGame) async {
    TiledManager self = TiledManager(myGame);

    self.tiled = await TiledComponent.load("map.tmx", Vector2.all(16));
    var imageBatch = ImageBatchCompiler();

    // プレイヤの下に表示
    self.underComponent = imageBatch.compileMapLayer(
        tileMap: self.tiled.tileMap, layerNames: ['UnderPlayer']);
    self.underComponent
      ..priority = Priority.mapUnder.index
      ..scale = Vector2.all(2);

    self.eventComponent = imageBatch.compileMapLayer(
        tileMap: self.tiled.tileMap, layerNames: ['UnderPlayerEvent']);
    self.eventComponent
      ..priority = Priority.mapUnder.index
      ..scale = Vector2.all(2);

    // プレイヤの上に表示
    self.overComponent = imageBatch.compileMapLayer(
        tileMap: self.tiled.tileMap, layerNames: ['OverPlayer']);
    self.overComponent
      ..priority = Priority.mapOver.index
      ..scale = Vector2.all(2);

    return self;
  }

  MapEventType checkEventType(int blockX, int blockY) {
    // 移動不可チェック
    var walkFlagLayerIndex =
        tiled.tileMap.map.layers.indexOf(tiled.tileMap.getLayer("walk-flag")!);
    if (tiled.tileMap
            .getTileData(layerId: walkFlagLayerIndex, x: blockX, y: blockY)
            ?.tile !=
        0) return MapEventType.wall; // 移動不可

    var event = getEvent(blockX, blockY);
    if (event != null) return MapEventType.event;

    return MapEventType.floor; // なにもない(床)
  }

  // イベントチェック
  String? getEvent(int blockX, int blockY) {
    // イベントチェック
    var eventGid = tiled.tileMap
        .getLayer<TileLayer>("UnderPlayerEvent")!
        .tileData![blockY][blockX];

    // イベントタイルが存在した
    if (eventGid.tile != 0) {
      // タイル情報のeventを読む
      String? s = tiled.tileMap.map
          .tileByGid(eventGid.tile)!
          .properties["event"]!
          .value as String?;

      if (s != null) return s;
    }

    // イベントは存在しなかった
    return null;
  }

  // タイルマップを状態に応じた表示にする
  void updateTilemap() {
    bool isUpdate = false;

    if (myGame.db.items.containsKey("key")) {
      TileLayer? layer = tiled.tileMap.getLayer<TileLayer>("UnderPlayerEvent");
      for (int y = 0; y < layer!.height; y++) {
        for (int x = 0; x < layer.width; x++) {
          if (layer.tileData?[y][x].tile == EventTile.treasure.id) {
            // 宝箱を空いた状態に
            layer.tileData?[y][x] =
                Gid(EventTile.treasureOpen.id, const Flips.defaults());

            // 更新が必要
            isUpdate = true;
            break;
          }
        }
      }
    }

    // 更新
    if (isUpdate) {
      myGame.remove(eventComponent);

      var imageBatch = ImageBatchCompiler();
      eventComponent = imageBatch.compileMapLayer(
          tileMap: tiled.tileMap, layerNames: ['UnderPlayerEvent']);
      eventComponent
        ..priority = Priority.mapUnder.index
        ..scale = Vector2.all(2);

      myGame.add(eventComponent);
    }
  }
}
