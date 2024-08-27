import 'package:my_app/Game/events/event_manager.dart';
import 'package:my_app/Game/my_game.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class EventActionBase extends EventElement {
  int actionStep = 0;
  EventActionBase(super.type);

  @override
  void update() {
    finish();
  }
}

abstract class LevelActionBase {
  final MyGame myGame;
  final int level; // ステージ番号

  String type = "";
  int actionStep = 0;

  LevelActionBase(this.myGame, this.level);

  bool get isPlaying => type.isNotEmpty;

  // アクションを開始する
  void start(String type) {
    log.info("call action start");
    this.type = type;
    actionStep = 0; // 最初から
  }

  // アクション終了
  void stop() {
    type = "";
  }

  // アクションを強制終了して初期状態に
  void reset() => start("on_start");

  void update() {
    if (isPlaying) onActionFinish(type);
  }

  void onActionFinish(String type) {
    log.info("finish action: $type");
    stop();

    // アクションが終わったらコマンド待ち
    // myGame.startIdle();
  }
}
