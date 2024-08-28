import 'package:my_app/Game/events/event_manager.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class LevelAction extends EventElement {
  int actionStep = 0;
  LevelAction(super.name);

  @override
  void update() {
    finish();
  }
}
