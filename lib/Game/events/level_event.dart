import 'package:flutter/material.dart';

import '../../UI_Widgets/message_window.dart';
import '../../my_logger.dart';

class LevelEvent {
  late Map msgEventData;
  LevelEvent(this.msgEventData);

  void checkMsgEvent() {
    const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
    msgWin.currentState
        ?.show(msgEventData["level1"]["MessageEvent"]["message"][0]);
  }

  void checkIdleEvent() {
    log.info("event check");
  }
}
