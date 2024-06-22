import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart';
import 'priorities.dart';

enum PlayerDir {
  down(0),
  left(1),
  right(2),
  up(3),
  ;

  final int id;
  const PlayerDir(this.id);
}

class PlayerComponent extends SpriteAnimationComponent {
  List<SpriteAnimation> walkAnim = [];

  PlayerComponent()
      : super(
          position: Vector2(240, 288), // 初期座標
          anchor: Anchor.bottomCenter,
          size: Vector2(48, 48),
          priority: Priority.player.index,
        );

  static Future<PlayerComponent> create() async {
    PlayerComponent self = PlayerComponent();

    final playerSheet = SpriteSheet.fromColumnsAndRows(
        image: await Flame.images.load('sample20160312.png'),
        columns: 18,
        rows: 12);

    for (int i = 0; i < 4; i++) {
      self.walkAnim.add(SpriteAnimation.fromFrameData(
          playerSheet.image,
          SpriteAnimationData([
            playerSheet.createFrameData(8 + i, 6, stepTime: 0.5),
            playerSheet.createFrameData(8 + i, 7, stepTime: 0.5),
            playerSheet.createFrameData(8 + i, 8, stepTime: 0.5),
            playerSheet.createFrameData(8 + i, 7, stepTime: 0.5),
          ])));
    }

    self.animation = self.walkAnim[PlayerDir.down.id];

    return self;
  }

  void setMove(PlayerDir dir) {
    setDir(dir);
  }

  void setDir(PlayerDir dir) {
    animation = walkAnim[dir.id];
  }
}
