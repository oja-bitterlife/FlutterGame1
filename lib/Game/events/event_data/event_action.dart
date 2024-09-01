import 'package:my_app/Game/player.dart';

import '../event_element.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

// アクション一つ
class EventAction extends EventElement {
  String command;
  EventAction(super.name, this.command);

  @override
  void onStart() {
    gameRef.player.setMove(PlayerDir.up);
  }

  @override
  void onUpdate() {
    // 移動完了
    if (!gameRef.player.isMoving) {
      finish();
    }
  }
}

// 複数アクションを順番に表示
class EventActionGroup extends EventQueue {
  EventActionGroup(super.name, String commands, [super.next]) {
    // データを確認して開始
    addAll(commands.split(",").map((command) => EventAction(name, command)));
  }
}

// イベントマネージャ用
EventActionGroup createEventAction(String name, String action, String? next) =>
    EventActionGroup(name, action, next);
