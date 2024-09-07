import '../../ui_control.dart';
import '../event_element.dart';

// ignore: unused_import
import '/my_logger.dart';

// メッセージ1つ表示
class EventMsg extends EventElement {
  // 表示UI
  String text;

  EventMsg(super.name, this.text);

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

// 一連のメッセージ表示
class EventMsgRoot extends EventElement {
  EventMsgRoot(super.name, String text, {super.next}) {
    addAll(formatEventMsg(text).map((text) => EventMsg(name, text)));
  }

  @override
  void onFinish() {
    gameRef.uiControl.showUI = ShowUI.cursor;
  }
}

// イベントマネージャ用
EventMsgRoot createEventMsg(String name, String data, EventElement? next) {
  return EventMsgRoot(name, data, next: next);
}
