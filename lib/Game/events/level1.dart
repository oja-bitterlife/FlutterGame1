import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:my_app/Game/player.dart';
import 'package:toml/toml.dart';
import 'package:flutter/material.dart';
import '../../UI_Widgets/message_window.dart';

import '../../Game/my_game.dart';
import '../../Game/priorities.dart';
import 'level_event.dart';

// ignore: unused_import
import '../../my_logger.dart';

class Level1Event extends LevelEvent {
  Level1Event(super.myGame, super.eventData);

  static create(MyGame myGame) async {
    var self = Level1Event(
        myGame,
        TomlDocument.parse(await rootBundle.loadString("assets/data/event.toml",
                cache: false))
            .toMap()["level1"]);
    return self;
  }

  @override
  void onFind(String type, int blockX, int blockY) {
    if (type == "treasure") {
      if (myGame.db.items.containsKey("key")) {
        startMessageEvent("has_key");
      } else {
        // 鍵を入手
        myGame.db.items["key"] = 1;
        myGame.map.updateTilemap(); // 宝箱更新

        startMessageEvent(type);
      }
    } else {
      super.onFind(type, blockX, blockY);
    }
  }

  @override
  void onMoved(int blockX, int blockY) {
    // Level1は動ける位置を固定
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

      addMessageEvent("trap", ["罠だ！"]);
      return;
    }

    // idleに戻す
    super.onMoved(blockX, blockY);
  }

  @override
  void onMessageFinish(String type) {
    log.info("finish event: $type");

    // ゲームオーバーに移行する
    if (type == "trap") {
      const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
      msgWin.currentState?.hide();

      myGame.add(
        TextComponent(
            text: 'Game Over',
            position: Vector2(80, 220),
            textRenderer: TextPaint(
                style: const TextStyle(fontSize: 64, color: Colors.white)),
            priority: Priority.GameOver.index),
      );
      return;
    }

    // idleに戻す
    super.onMessageFinish(type);
  }
}
