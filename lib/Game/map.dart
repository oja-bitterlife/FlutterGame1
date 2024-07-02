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

class TiledManager {
  static int blockSize = 32;
  late TiledComponent tiled;

  // 表示コンポーネント
  late final PositionComponent underComponent;
  late final PositionComponent overComponent;

  static Future<TiledManager> create(MyGame myGame) async {
    TiledManager self = TiledManager();

    self.tiled = await TiledComponent.load("map.tmx", Vector2.all(16));
    var imageBatch = ImageBatchCompiler();

    // プレイヤの下に表示
    self.underComponent = imageBatch.compileMapLayer(
        tileMap: self.tiled.tileMap, layerNames: ['UnderPlayer']);
    self.underComponent
      ..priority = Priority.mapUnder.index
      ..scale = Vector2.all(2);
    // myGame.add(underPlayer);

    // プレイヤの上に表示
    self.overComponent = imageBatch.compileMapLayer(
        tileMap: self.tiled.tileMap, layerNames: ['OverPlayer']);
    self.overComponent
      ..priority = Priority.mapOver.index
      ..scale = Vector2.all(2);
    // myGame.add(overPlayer);

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
      return tiled.tileMap.map
          .tileByGid(eventGid.tile)!
          .properties["event"]!
          .value as String?;
    }

    // イベントは存在しなかった
    return null;
  }
}
