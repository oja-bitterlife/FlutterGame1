import 'dart:collection';
import 'package:flame/components.dart';
import '../my_game.dart';

// ignore: unused_import
import '../../my_logger.dart';

typedef EventInfo = ({String? type, String? name});

class EventElement extends Component {
  final MyGame myGame;

  EventInfo current;
  EventInfo next = (type: null, name: null);

  bool isStarted = false;

  bool get isNotDefined => current.type == null || current.name == null;

  EventElement(this.myGame, String type, String name,
      [Iterable<Component>? list])
      : current = (type: type, name: name),
        super(children: list);

  EventElement.notDefined(this.myGame) : current = (type: null, name: null);

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
    log.info("finish $runtimeType:$current => $next");

    // nextがあれば次のイベントを登録
    if (next.type == null && next.name != null) {
      myGame.eventManager.addEvent(next.type!, next.name!);
    }
  }
}

class EventQueue extends EventElement {
  EventQueue(MyGame myGame, String type, String name)
      : super(myGame, type, name, Queue<EventElement>());

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
