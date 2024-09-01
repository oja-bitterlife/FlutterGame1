import 'package:flame/components.dart';
import '../my_game.dart';

// ignore: unused_import
import '../../my_logger.dart';

class EventElement extends Component with HasGameRef<MyGame> {
  String name;
  String? next;
  bool nofity;

  bool isStarted = false;

  EventElement(this.name, [this.next, this.nofity = false]);

  @override
  void update(double dt) {
    // 最初はupdateではなくonStartを実行する
    if (isStarted == false) {
      onStart();
      isStarted = true;
      return;
    }

    onUpdate();
    super.update(dt);
  }

  // 強制終了
  void stop() {
    removeFromParent();
  }

  // 通常終了
  void finish() {
    removeFromParent();
    onFinish();

    // nextがあれば次のイベントを登録
    if (next != null) {
      gameRef.eventManager.addEvent(next!);
    }

    // 終了を通知
    if (nofity) {
      gameRef.eventManager.onEventFinish(this);
    }
  }

  // 最初の一回
  void onStart() {}

  // 更新用
  void onUpdate() {}

  // 終了時
  void onFinish() {}
}

class EventQueue extends EventElement {
  EventQueue(super.name, [super.next, super.nofity = true]);

  // キューなので先頭1つだけ実行する
  @override
  void updateTree(double dt) {
    super.update(dt);

    if (hasChildren) {
      EventElement element = children.first as EventElement;
      element.updateTree(dt);
    } else {
      // キューが空っぽになった
      finish();
    }
  }
}
