import 'package:flame/game.dart';
import 'package:flame/Sprite.dart';
import 'package:flame/components.dart';
import 'priorities.dart';

class PlayerComponent extends SpriteAnimationComponent {
  PlayerComponent()
      : super(
          position: Vector2(240, 288), // 初期座標
          anchor: Anchor.bottomCenter,
          size: Vector2(48, 48),
          priority: Priority.player.index,
        );

  static Future<PlayerComponent> create(FlameGame gameRef) async {
    PlayerComponent self = PlayerComponent();

    final playerSheet = SpriteSheet.fromColumnsAndRows(
        image: await gameRef.images.load('sample20160312.png'),
        columns: 18,
        rows: 12);

    self.animation = SpriteAnimation.fromFrameData(
        playerSheet.image,
        SpriteAnimationData([
          playerSheet.createFrameData(8, 6, stepTime: 0.5),
          playerSheet.createFrameData(8, 7, stepTime: 0.5),
          playerSheet.createFrameData(8, 8, stepTime: 0.5),
          playerSheet.createFrameData(8, 7, stepTime: 0.5),
        ]));

    return self;
  }
}
