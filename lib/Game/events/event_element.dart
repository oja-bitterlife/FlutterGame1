import 'package:flame/components.dart';
import '../my_game.dart';

// ignore: unused_import
import '../../my_logger.dart';

class EventElement extends Component with HasGameRef<MyGame> {
  String? name, next;

  bool isStarted = false;

  bool get isEmpty => name?.isEmpty ?? true;
  bool get isNotEmpty => !isEmpty;

  EventElement(String this.name, [this.next]);
  EventElement.empty();

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
  }

  // 最初の一回
  void onStart() {}

  // 更新用
  void onUpdate() {}

  void onFinish() {
    log.info("finish $runtimeType:$name => $next");

    // nextがあれば次のイベントを登録
    if (next != null) {
      gameRef.eventManager.addEvent(next!);
    }
  }
}

class EventQueue extends EventElement {
  EventQueue(super.name, [super.next]);

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
