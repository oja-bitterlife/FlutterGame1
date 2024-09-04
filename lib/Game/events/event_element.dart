import 'package:flame/components.dart';
import 'package:my_app/Game/events/event_manager.dart';
import '../my_game.dart';

// ignore: unused_import
import '../../my_logger.dart';

// キュー方式で順番に子イベントを実行する
// 子が無くなったら自分
class EventElement extends Component {
  String name;
  EventElement? next;
  bool notice; // イベントの開始・終了通知コールバックを呼び出す

  bool isStarted = false;

  MyGame get gameRef => EventManager.myGame;
  EventManager get eventRef => EventManager.myGame.event;

  EventElement(this.name, {this.next, this.notice = false});

  @override
  void update(double dt) {
    onUpdate();
  }

  // キューなので先頭1つだけ実行する
  @override
  void updateTree(double dt) {
    // 最初はupdateではなくonStartを実行する
    if (isStarted == false) {
      isStarted = true; // 初回のみ

      // 開始を通知
      if (notice) {
        eventRef.onStartNotice(this);
      }

      onStart();
      return;
    }

    // 先頭の子だけ実行(元のupdateTreeは全部実行してしまう)
    if (hasChildren) {
      EventElement element = children.first as EventElement;
      element.updateTree(dt);
    }

    // キューが空なら自分を実行(updateTreeで空になった場合もすぐ呼ぶ)
    if (!hasChildren) update(dt);
  }

  // 強制終了
  void stop() {
    removeFromParent();
  }

  // 通常終了
  void finish() {
    removeFromParent();
    onFinish();

    // 終了を通知
    if (notice) {
      eventRef.onFinishNitice(this);
    }

    // nextがあれば次のイベントを登録
    if (next != null) {
      eventRef.add(next!);
    }
  }

  // 最初の一回
  void onStart() {}

  // 更新用
  void onUpdate() {
    finish(); // デフォルトは何もしないでそのまま終了
  }

  // 終了時
  void onFinish() {}
}
