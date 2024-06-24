import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:my_app/UI_Widgets/message_window.dart';

// ignore: unused_import
import '../my_logger.dart';
import '../Game/player.dart';
import '../Game/my_game.dart';

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

  // プレイヤの各方向(PlayerDir)のカーソルタイプ
  List<PlayerCursorType> PlayerCursorData = [
    PlayerCursorType.move,
    PlayerCursorType.move,
    PlayerCursorType.move,
    PlayerCursorType.move,
  ];
  // 一つの方向のカーソルタイプを設定する
  void setCursorType(PlayerCursorType type, PlayerDir dir) {
    setState(() {
      PlayerCursorData[dir.id] = type;
    });
  }

  // 一つの方向のカーソルタイプを設定し、それ以外はリセットする
  void setCursorOnce(PlayerCursorType type, PlayerDir dir) {
    resetCursorType();
    setCursorType(type, dir);
  }

  // 全ての方向のカーソルタイプをリセットする
  void resetCursorType() {
    setState(() {
      PlayerCursorData.fillRange(0, 4, PlayerCursorType.move);
    });
  }

  // 表示座標の設定
  void show(Vector2 pos) {
    setState(() {
      cursorPos.setFrom(pos);
      isVisible = true;
    });
  }

  // 非表示
  void hide() {
    setState(() {
      isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: isVisible,
        // 上下左右カーソル表示
        child: Stack(alignment: Alignment.topLeft, children: <Widget>[
          Positioned(
              left: cursorPos.x - 64,
              top: cursorPos.y - 44,
              child: IconButton(
                  onPressed: () {
                    onPlayerCursor(
                        PlayerCursorData[PlayerDir.left.id], PlayerDir.left);
                  },
                  icon: getIcon(
                      PlayerCursorData[PlayerDir.left.id], PlayerDir.left),
                  color: Colors.white,
                  iconSize: 32)),
          Positioned(
              left: cursorPos.x + 16,
              top: cursorPos.y - 44,
              child: IconButton(
                  onPressed: () {
                    onPlayerCursor(
                        PlayerCursorData[PlayerDir.right.id], PlayerDir.right);
                  },
                  icon: getIcon(
                      PlayerCursorData[PlayerDir.right.id], PlayerDir.right),
                  color: Colors.white,
                  iconSize: 32)),
          Positioned(
              left: cursorPos.x - 24,
              top: cursorPos.y - 88,
              child: IconButton(
                  onPressed: () {
                    onPlayerCursor(
                        PlayerCursorData[PlayerDir.up.id], PlayerDir.up);
                  },
                  icon:
                      getIcon(PlayerCursorData[PlayerDir.up.id], PlayerDir.up),
                  color: Colors.white,
                  iconSize: 32)),
          Positioned(
              left: cursorPos.x - 24,
              top: cursorPos.y - 4,
              child: IconButton(
                  onPressed: () {
                    onPlayerCursor(
                        PlayerCursorData[PlayerDir.down.id], PlayerDir.down);
                  },
                  icon: getIcon(
                      PlayerCursorData[PlayerDir.down.id], PlayerDir.down),
                  color: Colors.white,
                  iconSize: 32)),
        ]));
  }

  Icon getIcon(PlayerCursorType type, PlayerDir dir) {
    if (type == PlayerCursorType.move) {
      return switch (dir) {
        PlayerDir.up => const Icon(Icons.arrow_circle_up_outlined),
        PlayerDir.down => const Icon(Icons.arrow_circle_down_outlined),
        PlayerDir.left => const Icon(Icons.arrow_circle_left_outlined),
        PlayerDir.right => const Icon(Icons.arrow_circle_right_outlined),
      };
    }
    if (type == PlayerCursorType.find) {
      return const Icon(Icons.find_in_page_outlined);
    }
    return const Icon(Icons.no_adult_content);
  }

  // カーソルが押された時の処理
  void onPlayerCursor(PlayerCursorType type, PlayerDir dir) {
    hide(); // アクション中は隠す

    switch (type) {
      case PlayerCursorType.move:
        // 移動
        widget.myGame.player.setMove(dir);
      case PlayerCursorType.find:
        // 移動せず方向だけ変える
        widget.myGame.player.setDir(dir);
        // メッセージ表示
        const msgWin = GlobalObjectKey<MessageWindowState>("MessageWindow");
        msgWin.currentState?.show("あいうえお");
    }
  }
}
