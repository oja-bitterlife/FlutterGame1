import 'package:flutter/material.dart';
import 'package:flame/game.dart';

class PlayerCursorWidget extends StatefulWidget {
  const PlayerCursorWidget({super.key});

  @override
  PlayerCursorState createState() => PlayerCursorState();
}

class PlayerCursorState extends State<PlayerCursorWidget> {
  Vector2 cursorPos = Vector2.zero();
  bool isBuilded = false;
  bool isVisible = false;

  // 表示座標の設定
  void show(Vector2 pos) {
    cursorPos.setFrom(pos);
    isVisible = true;
    if (isBuilded) setState(() {}); // Build中に実行するとエラーになる
  }

  void hide() {
    isVisible = false;
    if (isBuilded) setState(() {}); // Build中に実行するとエラーになる
  }

  @override
  Widget build(BuildContext context) {
    // Build中を判別できるように
    isBuilded = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Build終了コールバックで完了フラグを立てておく
      isBuilded = true;
    });

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
