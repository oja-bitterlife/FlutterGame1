import 'package:flutter/material.dart';
import 'package:flame/game.dart';

class PlayerCursorWidget extends StatefulWidget {
  const PlayerCursorWidget({super.key});

  @override
  PlayerCursorState createState() => PlayerCursorState();
}

class PlayerCursorState extends State<PlayerCursorWidget> {
  Vector2 cursorPos = Vector2.zero();
  bool isVisible = false;

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
              left: cursorPos.x - 48,
              top: cursorPos.y - 32,
              child: const Icon(Icons.arrow_circle_left_outlined,
                  color: Colors.white)),
          Positioned(
              left: cursorPos.x + 24,
              top: cursorPos.y - 32,
              child: const Icon(Icons.arrow_circle_right_outlined,
                  color: Colors.white)),
          Positioned(
              left: cursorPos.x - 12,
              top: cursorPos.y - 72,
              child: const Icon(Icons.arrow_circle_up_outlined,
                  color: Colors.white)),
          Positioned(
              left: cursorPos.x - 12,
              top: cursorPos.y + 4,
              child:
                  const Icon(Icons.find_in_page_outlined, color: Colors.white)),
        ]));
  }
}
