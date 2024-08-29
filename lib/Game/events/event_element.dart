import '../my_game.dart';

// ignore: unused_import
import '../../my_logger.dart';

class EventInfo {
  final String? type;
  final String? name;
  EventInfo(this.type, this.name);

  const EventInfo.empty()
      : type = null,
        name = null;

  bool get isEmpty => type == null || name == null;
  bool get isNotEmpty => !isEmpty;

  @override
  String toString() {
    return "$type:$name";
  }
}

class EventElement extends EventInfo {
  final MyGame myGame;
  EventInfo next = const EventInfo.empty();

  EventElement(this.myGame, super.type, super.name,
      [this.next = const EventInfo.empty()]);

  EventElement.empty(this.myGame) : super.empty();

  // イベントループ
  void update() {}

  // 強制終了
  void stop() {
    myGame.eventManager.eventList.remove(this);
  }

  // 通常終了
  void finish() {
    myGame.eventManager.eventList.remove(this);
    onFinish();
  }

  void onFinish() {
    log.info("finish $runtimeType:$name => $next");

    // nextがあれば次のイベントを登録
    if (next.type != null && next.name != null) {
      myGame.eventManager.add(next.type!, next.name!);
    }
  }
}
