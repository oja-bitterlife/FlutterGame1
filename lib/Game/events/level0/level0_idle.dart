import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../my_game.dart';
import '../level_idle_base.dart';

import '../../priorities.dart';
import '../../player.dart';

// ignore: unused_import
import '../../../my_logger.dart';

const int GloalX = 7;
const int GloalY = 3;

class Level0Idle extends LevelIdleBase {
  Level0Idle(super.myGame);

  static create(MyGame myGame) async {
    var self = Level0Idle(myGame);
    return self;
  }

  @override
  void onIdle(int blockX, int blockY) {
    // Level0は動ける位置を固定
    bool isDead = true;
    if (blockX == 7) {
      isDead = false;
    } else if (blockY <= 10) {
      if (blockX >= 6 && blockX <= 8) {
        isDead = false;
      }
    }

    if (isDead) {
      var sp = myGame.trapSheet.getSprite(16, 5);
      myGame.add(SpriteComponent(
          sprite: sp,
          position: Vector2(PlayerComponent.getPosFromBlockX(blockX) - 32,
              PlayerComponent.getPosFromBlockY(blockY) - 64),
          priority: Priority.eventOver.index,
          scale: Vector2.all(2)));

      myGame.eventManager.startMessage("trap", data: ["罠だ！"]);
      return;
    }

    // ゴール判定
    if (blockX == GloalX && blockY == GloalY) {
      myGame.add(
        TextComponent(
            text: 'Lv.0 Clear!',
            position: Vector2(120, 220),
            textRenderer: TextPaint(
                style: const TextStyle(fontSize: 64, color: Colors.white)),
            priority: Priority.GameOver.index),
      );

      return;
    }

    // 通常のidleに戻す
    super.onIdle(blockX, blockY);
  }
}
