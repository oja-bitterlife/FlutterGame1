import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

// ignore: unused_import
import '../my_logger.dart';
import 'priorities.dart';

enum MapEventType {
  floor(0),
  wall(1),
  event(2),
  ;

  final int id;
  const MapEventType(this.id);
}

class MapComponent extends Component {
  static int blockSize = 32;
  late TiledComponent tiled;

  static Future<MapComponent> create() async {
    MapComponent self = MapComponent();

    self.add(self.tiled = await TiledComponent.load(
        "map.tmx", Vector2(blockSize.toDouble(), blockSize.toDouble()),
        priority: Priority.map.index));

    return self;
  }

  MapEventType check(int blockX, int blockY) {
    // 移動不可チェック
    var walkFlagLayerIndex =
        tiled.tileMap.map.layers.indexOf(tiled.tileMap.getLayer("walk-flag")!);
    if (tiled.tileMap
            .getTileData(layerId: walkFlagLayerIndex, x: blockX, y: blockY)
            ?.tile !=
        0) return MapEventType.wall; // 移動不可

    var event = checkEvent(blockX, blockY);
    if (event != null) return MapEventType.event;

    return MapEventType.floor; // なにもない(床)
  }

  // イベントチェック
  String? checkEvent(int blockX, int blockY) {
    // イベントチェック
    var eventLayerIndex =
        tiled.tileMap.map.layers.indexOf(tiled.tileMap.getLayer("event")!);
    var eventGid = tiled.tileMap
        .getTileData(layerId: eventLayerIndex, x: blockX, y: blockY);

    // イベントタイルが存在した
    if (eventGid?.tile != 0) {
      // タイル情報のeventを読む
      var eventTile = tiled.tileMap.map.tilesets[0].tiles[eventGid!.tile - 1];
      return eventTile.properties["event"]?.value as String?;
    }

    // イベントは存在しなかった
    return null;
  }
}
