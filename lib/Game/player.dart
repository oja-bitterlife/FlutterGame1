import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart';
import 'package:my_app/UI_Widgets/player_cursor.dart';

// ignore: unused_import
import '../my_logger.dart';
import 'my_game.dart';
import 'priorities.dart';
import 'map.dart';

enum PlayerDir {
  down(0),
  left(1),
  right(2),
  up(3),
  ;

  final int id;
  const PlayerDir(this.id);
}

class MovePlayerComponent extends PlayerComponent {
  // 移動中表示用データ
  static const needMoveTime = 0.5;
  double transTime = needMoveTime;
  Vector2 srcPos = Vector2.zero(), moveValue = Vector2.zero();

  // 移動開始
  void setMove(PlayerDir dir) {
    // 方向をまず変えておく
    setDir(dir);

    // 移動アニメリセット
    transTime = 0;
    srcPos.setFrom(position);

    // 移動先設定
    moveValue = switch (dir) {
      PlayerDir.down => Vector2(0, MapComponent.blockSize.toDouble()),
      PlayerDir.left => Vector2(-MapComponent.blockSize.toDouble(), 0),
      PlayerDir.right => Vector2(MapComponent.blockSize.toDouble(), 0),
      PlayerDir.up => Vector2(0, -MapComponent.blockSize.toDouble()),
    };

    const cursor = GlobalObjectKey<PlayerCursorState>("PlayerCursor");
    cursor.currentState?.hide();
  }

  // 移動中チェック
  bool isMoving() {
    return transTime < needMoveTime;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 移動中でなかった
    if (!isMoving()) return;

    // 移動中処理
    // ------------------------------------------------------------------------
    transTime = min(transTime + dt, needMoveTime); // 行き過ぎないように

    // 座標更新
    position = (moveValue * transTime / needMoveTime) + srcPos;

    // 移動が終わったときの処理(positionを確定させてから)
    if (!isMoving()) {
      startIdle(); // 待機開始
    }
  }

  void startIdle() {
    const cursor = GlobalObjectKey<PlayerCursorState>("PlayerCursor");

    // プレイヤーの四方向チェック
    int blockX = position.x.round() ~/ MapComponent.blockSize;
    int blockY = (position.y - MapComponent.blockSize * 0.5).round() ~/
        MapComponent.blockSize;
    cursor.currentState!
      ..setCursorType(checkEvent(blockX - 1, blockY), PlayerDir.left)
      ..setCursorType(checkEvent(blockX + 1, blockY), PlayerDir.right)
      ..setCursorType(checkEvent(blockX, blockY - 1), PlayerDir.up)
      ..setCursorType(checkEvent(blockX, blockY + 1), PlayerDir.down);

    // 操作カーソル表示
    cursor.currentState?.show(position);
  }

  PlayerCursorType checkEvent(int blockX, int blockY) {
    switch ((findGame() as MyGame).map.check(blockX, blockY)) {
      case MapEventType.event:
        return PlayerCursorType.find;
      case MapEventType.wall:
        return PlayerCursorType.none;
      default:
        return PlayerCursorType.move;
    }
  }
}

class PlayerComponent extends SpriteAnimationComponent with HasVisibility {
  List<SpriteAnimation> walkAnim = [];

  // 画像ロードはasyncなのでコンストラクタが使えない
  static late Sprite playerImage;
  static Future<void> load() async {
    playerImage = await Sprite.load('sample20160312.png');
  }

  PlayerComponent()
      : super(
          position: Vector2(240, 288), // 初期座標
          anchor: Anchor.bottomCenter,
          size: Vector2(48, 48),
          priority: Priority.player.index,
        ) {
    // イメージから歩きアニメスプライト切り出し
    var playerSheet = SpriteSheet.fromColumnsAndRows(
        image: playerImage.image, columns: 18, rows: 12);

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

  // 表示切り替え
  void setDir(PlayerDir dir) {
    animation = walkAnim[dir.id];
  }
}
