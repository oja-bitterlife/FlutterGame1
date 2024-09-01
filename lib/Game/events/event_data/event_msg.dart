import '../event_element.dart';
import '../../ui_control.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

// メッセージ1つ表示
class EventMsg extends EventElement {
  // 表示UI
  String text;

  EventMsg(super.name, this.text, [super.next, super.notify]);

  @override
  void onStart() {
    gameRef.uiControl.showUI = ShowUI.msgWin;
    gameRef.uiControl.msgWin?.setMsg(text);
  }

  @override
  void onUpdate() {
    if (gameRef.input.isTrgDown) finish();
  }
}

List<String> formatEventMsg(String text) {
  return text.replaceAll("\\n", "\n").split("\\0");
}

// メッセージ複数登録
class EventMsgRoot extends EventElement {
  EventMsgRoot(super.name, String text, [super.next, super.notify = true]) {
    addAll(formatEventMsg(text).map((text) => EventMsg(name, text)));
  }

  @override
  void onUpdate() {
    if (!hasChildren) finish();
  }

  @override
  void onFinish() {
    gameRef.uiControl.showUI = ShowUI.cursor;
  }
}

EventMsgRoot createEventMsg(String name, String text, String? next) {
  return EventMsgRoot(name, text, next);
}
