import 'package:flutter/services.dart';
import 'package:toml/toml.dart';

import '../../Game/my_game.dart';
import 'level_event.dart';

// ignore: unused_import
import '../../my_logger.dart';

class Level1 extends LevelEvent {
  Level1(super.myGame, super.eventData);

  static create(MyGame myGame) async {
    var self = Level1(
        myGame,
        TomlDocument.parse(await rootBundle.loadString("assets/data/event.toml",
                cache: false))
            .toMap()["level1"]);
    return self;
  }

  @override
  void onFind(String type, int blockX, int blockY) {
    if (type == "treasure") {
      startMessageEvent(type);
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
    } else if (blockY >= 8 && blockY <= 10) {
      if (blockX >= 6 && blockX <= 8) {
        isDead = false;
      }
    }

    if (isDead) {
      addMessageEvent("trap", ["罠だ！"]);
      return;
    }

    // idleに戻す
    super.onMoved(blockX, blockY);
  }

  @override
  void onMessageFinish(String type) {
    log.info("finish event: $type");

    // ログを表示する

    // idleに戻す
    super.onMessageFinish(type);
  }
}
