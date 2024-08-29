import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../my_game.dart';

import 'event_element.dart';
import 'level_msg.dart';

// ignore: unused_import
import '../../my_logger.dart';

import 'level_events/level0.dart';

class EventManager extends Component with TapCallbacks {
  late MyGame myGame;
  int currentLevel;

  EventManager(this.myGame, this.currentLevel)
      : super(key: ComponentKey.named("EventManager"));

  void addEvent(String type, String name) {
    EventElement element = switch (type) {
      "msg" => EventMsgGroup.fromDB(myGame, name),
      "action" => getEventLv0(myGame, type, name),
      _ => EventElement.notDefined(myGame),
    };

    // 見知らぬイベントタイプ
    if (element.isNotDefined) {
      log.info("event not found: $type:$name");
      return;
    }

    add(element);
  }

  // マップ上にイベントが存在するか調べる
  String? getMapEvent(int blockX, int blockY) {
    // 上書きイベントを確認
    var eventName = myGame.userData.mapEvent.get(blockX, blockY);
    if (eventName != null) return eventName; // イベント名を返す

    // マップのイベントを確認
    int gid = myGame.map.getEventGid(blockX, blockY);
    if (gid != 0) {
      return myGame.map.getTilesetProperty(gid, "event");
    }

    // イベントは特になかった
    return null;
  }

  // Findアイコンが押された(イベントオブジェクトがある)
  void onFind(int blockX, int blockY) {
    String? type = getMapEvent(blockX, blockY);
    if (type != null) {
      // message.onFind(type, blockX, blockY);
    }
  }

  void onMsgTap() {
    // for (var event in eventList) {
    //   if (event is EventMessage) {
    //     event.nextPage();
    //   }
    // }
  }
  @override
  void onTapDown(TapDownEvent event) {
    // ゲーム画面のタップ処理。たぶん今回は使わない
    log.info("onEventTap");
  }

  // 移動終了時イベント
  void onMoveFinish(int blockX, int blockY) {
    // move.onMoveFinish(blockX, blockY);
  }
}
