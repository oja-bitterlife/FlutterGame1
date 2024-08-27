import 'package:my_app/Game/events/event_manager.dart';

// ignore: unused_import
import 'package:my_app/my_logger.dart';

class LevelActionBase extends EventElement {
  int actionStep = 0;
  LevelActionBase(super.type);

  @override
  void update() {
    finish();
  }
}
