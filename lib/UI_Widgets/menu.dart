import 'package:flutter/material.dart';

// ignore: unused_import
import '../my_logger.dart';
import '../Game/my_game.dart';

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
            myGame.reset();
            myGame.userData.reset();
            myGame.event.add(myGame.event.fromDB("on_start"));
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
            if (myGame.userData.hasSave()) {
              myGame.reset();
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
