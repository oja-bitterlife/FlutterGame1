import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

// ignore: unused_import
import '../my_logger.dart';
import 'priorities.dart';

class MapComponent extends Component {
  static Future<MapComponent> create() async {
    MapComponent self = MapComponent();

    self.add(await TiledComponent.load("map.tmx", Vector2(32.0, 32.0),
        priority: Priority.map.index));

    return self;
  }
}
