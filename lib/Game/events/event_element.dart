import 'package:flame/components.dart';
import '../my_game.dart';

// ignore: unused_import
import '../../my_logger.dart';

// キュー方式で順番に子イベントを実行する
// 子が無くなったら自分
class EventElement extends Component with HasGameRef<MyGame> {
  String name;
  EventElement? next;
  bool nofity; // EventManagerのonEventFinishを呼び出す

  bool isStarted = false;

  EventElement(this.name, [this.next, this.nofity = false]);

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
      if (nofity) {
        gameRef.event.onStartNotice(this);
      }

      onStart();
      return;
    }

    // 子を一つ実行
    if (hasChildren) {
      EventElement element = children.first as EventElement;
      element.updateTree(dt);
    }
    // キューが空なら自分を実行
    else {
      update(dt);
    }
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
      gameRef.event.add(next!);
    }

    // 終了を通知
    if (nofity) {
      gameRef.event.onFinishNitice(this);
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
