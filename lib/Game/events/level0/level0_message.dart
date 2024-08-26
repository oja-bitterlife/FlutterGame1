import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../UI_Widgets/message_window.dart';

import '../../my_game.dart';
import '../../priorities.dart';
import '../level_message_base.dart';

// ignore: unused_import
import '../../../my_logger.dart';

// イベントが発生するタイル
enum EventTile {
  doorUp(153),
  doorDown(165),
  doorUpOpen(177),
  doorDownOpen(189),
  gate(460),
  gateSensor(447),
  gateSensorOpen(423),
  letter(508),
  treasure(372),
  treasureOpen(373),
  bedside(714),
  ;

  final int id;
  const EventTile(this.id);
}

class Level0Message extends LevelMessageBase {
  Level0Message(super.myGame, super.level);

  static create(MyGame myGame) async {
    var self = Level0Message(myGame, 0);
    return self;
  }

  @override
  void onFind(String type, int blockX, int blockY) {
    // 宝箱
    if (type == "treasure") {
      // 鍵を入手
      myGame.userData.items.obtain("key");

      //   // 宝箱表示更新
      //   // myGame.map.changeEvent(blockX, blockY, EventTile.treasureOpen.id);
      //   myGame.map.updateEventComponent();
      // }
      return super.startEvent(type, blockX, blockY);
    }

    // ゲートセンサー
    if (type == "gate") {
      // 鍵を持っていたらドアを開ける
      if (myGame.userData.items.has("key") == null) {
        // 鍵を使う
        type = "gate_with_key";
        myGame.userData.items.use("key");
      }

      return super.startEvent(type, blockX, blockY);
    }

    // メッセージイベント
    super.startEvent(type, blockX, blockY);
  }

  @override
  void onMessageFinish(
      String type, int blockX, int blockY, String? changeNext) {
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

    if (type == "gate_with_key") {
      // ドアオープン表示
      // myGame.map.changeEvent(myGame.player.getFowardBlockX(),
      //     myGame.player.getFowardBlockY() - 1, EventTile.gateSensorOpen.id);
      // myGame.map.changeEvent(myGame.player.getFowardBlockX() + 1,
      //     myGame.player.getFowardBlockY() - 1, EventTile.doorDownOpen.id);
      // myGame.map.changeEvent(myGame.player.getFowardBlockX() + 1,
      //     myGame.player.getFowardBlockY() - 2, EventTile.doorUpOpen.id);

      myGame.userData.movable.set(myGame.player.getFowardBlockX() + 1,
          myGame.player.getFowardBlockY() - 1, true);

      myGame.map.updateEventComponent();
    }

    // idleに戻す
    super.onMessageFinish(type, blockX, blockY, changeNext);
  }
}
