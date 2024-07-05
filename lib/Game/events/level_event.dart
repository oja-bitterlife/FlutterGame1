import 'package:flutter/material.dart';

import '../../UI_Widgets/message_window.dart';
import '../../my_logger.dart';

class LevelEvent {
  late Map msgEventData;
  LevelEvent(this.msgEventData);

  void msgEvent(String eventType) {
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState
        ?.show(msgEventData["level1"]["MessageEvent"]["message"][0]);
  }

  bool idleEvent(int blockX, int blockY) {
    bool isDead = true;
    if (blockX == 7) {
      isDead = false;
    } else if (blockY >= 10 && blockY <= 12) {
      if (blockX >= 6 && blockX < 8) {
        isDead = false;
      }
    }

    if (isDead) {
      const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
      msgWin.currentState?.show("罠だ！");
    }

    // 死んでたらイベント通知
    return isDead;
  }
}
