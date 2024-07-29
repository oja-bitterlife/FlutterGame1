import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:my_app/Game/map.dart';
import 'package:toml/toml.dart';
import 'package:flutter/material.dart';
import '../../../UI_Widgets/message_window.dart';

import '../../my_game.dart';
import '../../priorities.dart';
import '../level_message_base.dart';

// ignore: unused_import
import '../../../my_logger.dart';

class Level0Message extends LevelMessageBase {
  Level0Message(super.myGame, super.eventData);

  static create(MyGame myGame) async {
    var self = Level0Message(
        myGame,
        TomlDocument.parse(await rootBundle.loadString("assets/data/event.toml",
                cache: false))
            .toMap()["level1"]);
    return self;
  }

  @override
  void onFind(String type, int blockX, int blockY) {
    // 宝箱
    if (type == "treasure") {
      // 鍵を入手
      myGame.db.items["key"] = 1;

      // 宝箱表示更新
      myGame.map.changeEvent(blockX, blockY, EventTile.treasureOpen.id);
      myGame.map.updateEventComponent();
    }

    // ゲートセンサー
    if (type == "gate") {
      if (myGame.db.items.containsKey("key")) {
        type = "gate_with_key";
      }
    }

    super.onFind(type, blockX, blockY);
  }

  @override
  void onMessageFinish(String type) {
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
