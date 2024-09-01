import 'level_base.dart';
import 'package:my_app/Game/events/event_element.dart';

// ignore: unused_import
import '../../../my_logger.dart';

class Level0 extends LevelEventBase {
  Level0(super.myGame);

  @override
  void onEventFinish(EventElement event) {
    if (event.name == "treasure") {
      myGame.userData.items.obtain("key");
      log.info(myGame.userData.items.isOwned("key"));
    }
    if (event.name == "gate_with_key") {
      myGame.userData.items.use("key");
    }

    // TODO: implement onEventFinish
    // log.info(event.name);
  }
}
