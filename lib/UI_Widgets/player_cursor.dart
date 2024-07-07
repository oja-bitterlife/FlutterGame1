import 'package:flutter/material.dart';
import 'package:flame/game.dart';

// ignore: unused_import
import '../my_logger.dart';
import '../Game/player.dart';
import '../Game/my_game.dart';

enum PlayerCursorType {
  none(-1),
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
  List<PlayerCursorType> playerCursorData = [
    PlayerCursorType.none,
    PlayerCursorType.none,
    PlayerCursorType.none,
    PlayerCursorType.none,
  ];
  // 一つの方向のカーソルタイプを設定する
  void setCursorType(PlayerCursorType type, PlayerDir dir) {
    setState(() {
      playerCursorData[dir.id] = type;
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
              child: Visibility(
                  visible: playerCursorData[PlayerDir.left.id] !=
                      PlayerCursorType.none,
                  child: IconButton(
                      onPressed: () {
                        onPlayerCursor(playerCursorData[PlayerDir.left.id],
                            PlayerDir.left);
                      },
                      icon: getIcon(
                          playerCursorData[PlayerDir.left.id], PlayerDir.left),
                      color: Colors.white,
                      iconSize: 32))),
          Positioned(
              left: cursorPos.x + 16,
              top: cursorPos.y - 44,
              child: Visibility(
                  visible: playerCursorData[PlayerDir.right.id] !=
                      PlayerCursorType.none,
                  child: IconButton(
                      onPressed: () {
                        onPlayerCursor(playerCursorData[PlayerDir.right.id],
                            PlayerDir.right);
                      },
                      icon: getIcon(playerCursorData[PlayerDir.right.id],
                          PlayerDir.right),
                      color: Colors.white,
                      iconSize: 32))),
          Positioned(
              left: cursorPos.x - 24,
              top: cursorPos.y - 88,
              child: Visibility(
                  visible: playerCursorData[PlayerDir.up.id] !=
                      PlayerCursorType.none,
                  child: IconButton(
                      onPressed: () {
                        onPlayerCursor(
                            playerCursorData[PlayerDir.up.id], PlayerDir.up);
                      },
                      icon: getIcon(
                          playerCursorData[PlayerDir.up.id], PlayerDir.up),
                      color: Colors.white,
                      iconSize: 32))),
          Positioned(
              left: cursorPos.x - 24,
              top: cursorPos.y - 4,
              child: Visibility(
                  visible: playerCursorData[PlayerDir.down.id] !=
                      PlayerCursorType.none,
                  child: IconButton(
                      onPressed: () {
                        onPlayerCursor(playerCursorData[PlayerDir.down.id],
                            PlayerDir.down);
                      },
                      icon: getIcon(
                          playerCursorData[PlayerDir.down.id], PlayerDir.down),
                      color: Colors.white,
                      iconSize: 32))),
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
        // 方向を変えてからイベント
        widget.myGame.player.dir = dir;

        // イベント発生
        int blockX = widget.myGame.player.getFowardBlockX();
        int blockY = widget.myGame.player.getFowardBlockY();
        widget.myGame.eventManager.onFind(blockX, blockY);
      case PlayerCursorType.none:
        log.shout("あってはいけないエラー");
    }
  }
}
