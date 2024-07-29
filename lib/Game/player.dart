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

  static PlayerDir fromID(int id) {
    return switch (id) {
      0 => down,
      1 => left,
      2 => right,
      3 => up,
      _ => down, // とりあえず下
    };
  }
}

class MovePlayerComponent extends PlayerComponent {
  // 移動中表示用データ
  static const needMoveTime = 0.5;
  double transTime = needMoveTime;
  Vector2 srcPos = Vector2.zero(), moveValue = Vector2.zero();

  MovePlayerComponent(super.myGame);

  // 移動開始
  void setMove(PlayerDir dir) {
    // 方向をまず変えておく
    this.dir = dir;

    // 移動アニメリセット
    transTime = 0;
    srcPos.setFrom(position);

    // 移動先設定
    moveValue = switch (dir) {
      PlayerDir.down => Vector2(0, TiledMap.blockSize.toDouble()),
      PlayerDir.left => Vector2(-TiledMap.blockSize.toDouble(), 0),
      PlayerDir.right => Vector2(TiledMap.blockSize.toDouble(), 0),
      PlayerDir.up => Vector2(0, -TiledMap.blockSize.toDouble()),
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
      myGame.db.playerBlockX = getBlockX();
      myGame.db.playerBlockY = getBlockY();

      // Idle開始
      myGame.eventManager.onIdle(getBlockX(), getBlockY());
    }
  }
}

class PlayerComponent extends SpriteAnimationComponent with HasVisibility {
  final MyGame myGame;

  // 歩きアニメ
  List<SpriteAnimation> walkAnim = [];

  // 画像ロードはasyncなのでコンストラクタが使えない
  static late Sprite playerImage;
  static Future<void> load() async {
    playerImage = await Sprite.load('sample20160312.png');
  }

  PlayerComponent(this.myGame)
      : super(
          position: Vector2(getPosFromBlockX(myGame.db.playerBlockX),
              getPosFromBlockY(myGame.db.playerBlockY)), // 初期座標
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

    animation = walkAnim[dir.id];
  }

  // 表示切り替え
  set dir(PlayerDir dir) {
    myGame.db.playerDir = dir;
    animation = walkAnim[dir.id];
  }

  PlayerDir get dir => myGame.db.playerDir;

  // 位置->ブロック座標
  int getBlockX() {
    return position.x.round() ~/ TiledMap.blockSize;
  }

  int getBlockY() {
    return (position.y - TiledMap.blockSize * 0.5).round() ~/
        TiledMap.blockSize;
  }

  // 位置->向き先ブロック座標
  int getFowardBlockX() {
    return getBlockX() +
        switch (dir) {
          PlayerDir.up => 0,
          PlayerDir.down => 0,
          PlayerDir.left => -1,
          PlayerDir.right => 1,
        };
  }

  int getFowardBlockY() {
    return getBlockY() +
        switch (dir) {
          PlayerDir.up => -1,
          PlayerDir.down => 1,
          PlayerDir.left => 0,
          PlayerDir.right => 0,
        };
  }

  // ブロック座標->位置
  static double getPosFromBlockX(int blockX) {
    return blockX * TiledMap.blockSize + TiledMap.blockSize * 0.5;
  }

  static double getPosFromBlockY(int blockY) {
    return (blockY + 1) * TiledMap.blockSize as double;
  }
}
