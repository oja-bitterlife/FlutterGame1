import 'package:flutter/material.dart';
import 'save_load.dart';

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
            myGame.reset(myGame.currentLv);
            myGame.userData.reset();
            myGame.event.add(myGame.event.createFromDB("on_start"));
            Navigator.of(context).pop(); // メニューは閉じる
          },
        ),
        ListTile(
            title: const Text('Save/Load'),
            onTap: () async {
              Navigator.of(context).pop(); // メニューは閉じる

              await showDialog(
                  context: context,
                  builder: (context) {
                    return SaveLoadDialog(myGame);
                  });
            }),
      ],
    );
  }
}
