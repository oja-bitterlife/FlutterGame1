import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

// ignore: unused_import
import '../my_logger.dart';
import 'priorities.dart';

class MapComponent extends Component {
  static const int blockSize = 32;
  late TiledComponent tiled;

  static Future<MapComponent> create() async {
    MapComponent self = MapComponent();

    self.add(self.tiled = await TiledComponent.load(
        "map.tmx", Vector2(blockSize.toDouble(), blockSize.toDouble()),
        priority: Priority.map.index));

    return self;
  }

  int check(int blockX, int blockY) {
    var gid = tiled.tileMap.getTileData(layerId: 0, x: blockX, y: blockY);
    log.info(gid?.tile);

    if (gid?.tile == 218) return 2; // 宝箱
//    return 1; // 移動不可

    return 0; // なにもない(床)
  }
}
