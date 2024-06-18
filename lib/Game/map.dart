import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'priorities.dart';

class MapComponent extends Component {
  static Future<MapComponent> load() async {
    MapComponent self = MapComponent();

    self.add(await TiledComponent.load("map.tmx", Vector2(32.0, 32.0),
        priority: Priority.map.index));

    return self;
  }
}
