import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../Game/player.dart';
import '../Game/my_game.dart';
import '../logger.dart';

enum PlayerCursorType {
  move(0),
  find(1),
  ;

  final int id;
  const PlayerCursorType(this.id);
}

class PlayerCursorWidget extends StatefulWidget {
  final MyGame myGame;
  const PlayerCursorWidget({super.key, required this.myGame});

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
    setState(() {}); // 更新
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
                    onButton(PlayerCursorType.move, PlayerDir.left);
                  },
                  icon: const Icon(Icons.arrow_circle_left_outlined),
                  color: Colors.white,
                  iconSize: 32)),
          Positioned(
              left: cursorPos.x + 16,
              top: cursorPos.y - 44,
              child: IconButton(
                  onPressed: () {
                    onButton(PlayerCursorType.move, PlayerDir.right);
                  },
                  icon: const Icon(Icons.arrow_circle_right_outlined),
                  color: Colors.white,
                  iconSize: 32)),
          Positioned(
              left: cursorPos.x - 24,
              top: cursorPos.y - 88,
              child: IconButton(
                  onPressed: () {
                    onButton(PlayerCursorType.move, PlayerDir.up);
                  },
                  icon: const Icon(Icons.arrow_circle_up_outlined),
                  color: Colors.white,
                  iconSize: 32)),
          Positioned(
              left: cursorPos.x - 24,
              top: cursorPos.y - 4,
              child: IconButton(
                  onPressed: () {
                    onButton(PlayerCursorType.find, PlayerDir.down);
                  },
                  icon: const Icon(Icons.find_in_page_outlined),
                  color: Colors.white,
                  iconSize: 32)),
        ]));
  }

  void onButton(PlayerCursorType type, PlayerDir dir) {
    widget.myGame.player.setDir(dir);
  }
}
