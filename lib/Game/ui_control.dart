import 'package:flutter/material.dart';

import '/UI_Widgets/player_cursor.dart';
import '/UI_Widgets/message_window.dart';

// ignore: unused_import
import '/my_logger.dart';

enum ShowUI {
  none(0),
  msgWin(1),
  cursor(2),
  ;

  final int id;
  const ShowUI(this.id);
}

class UIControl {
  ShowUI showUI = ShowUI.none;

  MessageWindowState? get msgWin =>
      const GlobalObjectKey<MessageWindowState>("MessageWindow").currentState;
  PlayerCursorState? get cursor =>
      const GlobalObjectKey<PlayerCursorState>("PlayerCursor").currentState;

  void update() {
    if (showUI == ShowUI.none) {
      if (msgWin?.isVisible ?? false) msgWin?.visible = false;
      if (cursor?.isVisible ?? false) cursor?.visible = false;
      return;
    }

    if (showUI == ShowUI.msgWin) {
      if (!(msgWin?.isVisible ?? false)) msgWin?.visible = true;
      if (cursor?.isVisible ?? false) cursor?.visible = false;
      return;
    }

    if (showUI == ShowUI.cursor) {
      if (msgWin?.isVisible ?? false) msgWin?.visible = false;
      if (!(cursor?.isVisible ?? false)) cursor?.visible = true;
      return;
    }
  }
}
