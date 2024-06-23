import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../logger.dart';

class PlayerCursorWidget extends StatefulWidget {
  const PlayerCursorWidget({super.key});

  @override
  PlayerCursorState createState() => PlayerCursorState();
}

class PlayerCursorState extends State<PlayerCursorWidget> {
  Vector2 cursorPos = Vector2.zero();
  bool isVisible = true;

  // 表示座標の設定
  void show(Vector2 pos) {
    cursorPos.setFrom(pos);
    isVisible = true;
  }

  void hide() {
    isVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: isVisible,
        child: Stack(alignment: Alignment.topLeft, children: <Widget>[
          Positioned(
              left: cursorPos.x - 64,
              top: cursorPos.y - 44,
              child: IconButton(
                  onPressed: () {
                    log.info("left");
                  },
                  icon: const Icon(Icons.arrow_circle_left_outlined),
                  color: Colors.white,
                  iconSize: 32)),
          Positioned(
              left: cursorPos.x + 16,
              top: cursorPos.y - 44,
              child: IconButton(
                  onPressed: () {
                    log.info("right");
                  },
                  icon: const Icon(Icons.arrow_circle_right_outlined),
                  color: Colors.white,
                  iconSize: 32)),
          Positioned(
              left: cursorPos.x - 24,
              top: cursorPos.y - 88,
              child: IconButton(
                  onPressed: () {
                    log.info("up");
                  },
                  icon: const Icon(Icons.arrow_circle_up_outlined),
                  color: Colors.white,
                  iconSize: 32)),
          Positioned(
              left: cursorPos.x - 24,
              top: cursorPos.y - 4,
              child: IconButton(
                  onPressed: () {
                    log.info("find");
                  },
                  icon: const Icon(Icons.find_in_page_outlined),
                  color: Colors.white,
                  iconSize: 32)),
        ]));
  }
}
