import 'package:flutter/material.dart';
import 'package:my_app/Game/user_data.dart';

// ignore: unused_import
import '../my_logger.dart';
import '../Game/my_game.dart';
import '../Game/map.dart';

class Menu extends StatelessWidget {
  final MyGame myGame;
  const Menu({super.key, required this.myGame});

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
            myGame.userData.reset();
            Navigator.of(context).pop(); // メニューは閉じる
          },
        ),
        ListTile(
          title: const Text('Save'),
          onTap: () {
            myGame.userData.save();
            Navigator.of(context).pop(); // メニューは閉じる
          },
        ),
        ListTile(
          title: const Text('Load'),
          onTap: () {
            if (myGame.userData.hasPlayerSave) {
              myGame.restart();
              myGame.userData.load();
            }
            Navigator.of(context).pop(); // メニューは閉じる
          },
          subtitle: Text(myGame.userData.getTime()),
        ),
      ],
    );
  }
}
