import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart';
import 'priorities.dart';
import 'dart:ui';

enum PlayerDir {
  down(0),
  left(1),
  right(2),
  up(3),
  ;

  final int id;
  const PlayerDir(this.id);
}

class PlayerMoveComponent extends PlayerComponent {
  static const needMoveTime = 1.0;
  bool isMoving = false;
  double transTime = needMoveTime;
  Vector2 srcPos = Vector2.zero(), moveValue = Vector2.zero();

  // 移動開始
  void setMove(PlayerDir dir) {
    setDir(dir);

    isMoving = true;
    transTime = 0;
    srcPos = position;

    moveValue = switch (dir) {
      PlayerDir.down => Vector2(0, 48),
      PlayerDir.left => Vector2(-48, 0),
      PlayerDir.right => Vector2(48, 0),
      PlayerDir.up => Vector2(0, -48),
    };
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 移動中でなかった
    if (!isMoving) return;

    // 移動中
    transTime += dt;
    if (transTime > needMoveTime) {
      transTime = needMoveTime;
      isMoving = false; // 移動完了
    }

    // 座標更新
    position = (moveValue * transTime / needMoveTime) + srcPos;
  }
}

class PlayerComponent extends SpriteAnimationComponent {
  List<SpriteAnimation> walkAnim = [];

  static late Image image;
  static Future<void> load() async {
    image = await Flame.images.load('sample20160312.png');
  }

  PlayerComponent()
      : super(
          position: Vector2(240, 288), // 初期座標
          anchor: Anchor.bottomCenter,
          size: Vector2(48, 48),
          priority: Priority.player.index,
        ) {
    var playerSheet =
        SpriteSheet.fromColumnsAndRows(image: image, columns: 18, rows: 12);

    for (int i = 0; i < 4; i++) {
      walkAnim.add(SpriteAnimation.fromFrameData(
          playerSheet.image,
          SpriteAnimationData([
            playerSheet.createFrameData(8 + i, 6, stepTime: 0.5),
            playerSheet.createFrameData(8 + i, 7, stepTime: 0.5),
            playerSheet.createFrameData(8 + i, 8, stepTime: 0.5),
            playerSheet.createFrameData(8 + i, 7, stepTime: 0.5),
          ])));
    }

    animation = walkAnim[PlayerDir.down.id];
  }

  void setDir(PlayerDir dir) {
    animation = walkAnim[dir.id];
  }
}
