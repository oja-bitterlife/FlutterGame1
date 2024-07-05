import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toml/toml.dart';

import '../../Game/my_game.dart';
import '../../UI_Widgets/message_window.dart';
import 'level_event.dart';

// ignore: unused_import
import '../../my_logger.dart';

class Level1 extends LevelEvent {
  Level1(super.myGame, super.msgEventData);

  static create(MyGame myGame) async {
    var self = Level1(
        myGame,
        TomlDocument.parse(await rootBundle.loadString("assets/data/event.toml",
                cache: false))
            .toMap());
    return self;
  }

  @override
  void onFind(int blockX, int blockY) {
    var find = myGame.map.getEvent(blockX, blockY);

    if (find == "treasure") {
      // メッセージ表示
      myGame.eventManager.startMsgList(
          List<String>.from(msgEventData["level1"]["MessageEvent"]["message"]));
    }
  }

  @override
  bool checkIdleEvent(int blockX, int blockY) {
    // Level1は動ける位置を固定
    bool isDead = true;
    if (blockX == 7) {
      isDead = false;
    } else if (blockY >= 8 && blockY <= 10) {
      if (blockX >= 6 && blockX <= 8) {
        isDead = false;
      }
    }

    if (isDead) {
      myGame.eventManager.startMsgList(["罠だ！"]);
    }

    // 死んでたらイベント通知
    return isDead;
  }
}
