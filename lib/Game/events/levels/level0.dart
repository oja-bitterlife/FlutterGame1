import 'level_base.dart';
import 'package:my_app/Game/events/event_element.dart';

// ignore: unused_import
import '../../../my_logger.dart';

class Level0 extends LevelEventBase {
  Level0(super.myGame);

  @override
  void onEventFinish(EventElement event) {
    // TODO: implement onEventFinish
    // log.info(event.name);
  }
}
