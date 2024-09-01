import 'package:flutter/material.dart';
import '../../../UI_Widgets/player_cursor.dart';

import '../event_element.dart';
import 'package:my_app/Game/player.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

// 移動のみ(アクション用)
class EventMove extends EventElement {
  PlayerDir dir;
  EventMove(this.dir, [String? next, bool notify = false])
      : super("move: ${dir.toString()}", next, notify);

  @override
  void onStart() {
    gameRef.player.setMove(dir);
  }

  @override
  void onUpdate() {
    if (!gameRef.player.isMoving) finish();
  }
}

// 移動後カーソル表示
class EventMoveToIdle extends EventMove {
  EventMoveToIdle(super.dir, [super.next, super.notify = true]);

  @override
  void onFinish() {
    var cursor =
        const GlobalObjectKey<PlayerCursorState>("PlayerCursor").currentState;
    cursor?.showFromArea();
  }
}
