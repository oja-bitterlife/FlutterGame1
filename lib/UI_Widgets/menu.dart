import 'package:flutter/material.dart';
import 'package:flame/game.dart';

// ignore: unused_import
import '../my_logger.dart';
import '../Game/my_game.dart';

class Menu extends StatelessWidget {
  final MyGame myGame;
  Menu({super.key, required this.myGame});

  Vector2 cursorPos = Vector2.zero();
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(
            height: 64,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Main Menu'),
            )),
        ListTile(
          title: const Text('リスタート'),
          onTap: () {
            myGame.restart();
            Navigator.of(context).pop(); // メニューは閉じる
          },
        ),
      ],
    );
  }
}
