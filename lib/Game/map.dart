import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

// ignore: unused_import
import '../my_logger.dart';
import 'priorities.dart';

class MapComponent extends Component {
  static const int blockSize = 32;

  static Future<MapComponent> create() async {
    MapComponent self = MapComponent();

    self.add(await TiledComponent.load(
        "map.tmx", Vector2(blockSize.toDouble(), blockSize.toDouble()),
        priority: Priority.map.index));

    return self;
  }

  int check(int blockX, int blockY) {
    return 0; // なにもない(床)
//    return 1; // 移動不可
  }
}
