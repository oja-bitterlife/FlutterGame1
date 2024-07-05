import 'level_event.dart';
import 'package:toml/toml.dart';
import 'package:flutter/services.dart';

class Level1 extends LevelEvent {
  Level1(super.msgEventData);

  static create() async {
    var self = Level1(TomlDocument.parse(
            await rootBundle.loadString("assets/data/event.toml", cache: false))
        .toMap());
    return self;
  }
}
