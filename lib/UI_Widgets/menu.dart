import 'package:flutter/material.dart';
import 'package:my_app/Game/save_load.dart';

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
            myGame.saveLoad
                .reset(TiledMap.orgEventTiles(), TiledMap.orgEventTiles());
            myGame.restart(true);
            Navigator.of(context).pop(); // メニューは閉じる
          },
        ),
        ListTile(
          title: const Text('Save'),
          onTap: () {
            myGame.saveLoad.save();
            Navigator.of(context).pop(); // メニューは閉じる
          },
        ),
        ListTile(
          title: const Text('Load'),
          onTap: () {
            if (myGame.saveLoad.hasPlayerSave) {
              myGame.restart(false);
              myGame.saveLoad.load();
            }
            Navigator.of(context).pop(); // メニューは閉じる
          },
          subtitle: Text(myGame.saveLoad.getTime()),
        ),
      ],
    );
  }
}
