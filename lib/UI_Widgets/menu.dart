import 'package:flutter/material.dart';
import 'package:my_app/Game/game_db.dart';

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
            myGame.db = GameDB(myGame, TiledMap.getEventTiles());
            myGame.restart(true);
            Navigator.of(context).pop(); // メニューは閉じる
          },
        ),
        ListTile(
          title: const Text('Save'),
          onTap: () {
            myGame.db.save();
            Navigator.of(context).pop(); // メニューは閉じる
          },
        ),
        ListTile(
          title: const Text('Load'),
          onTap: () {
            myGame.db.load();
            myGame.restart(false);
            Navigator.of(context).pop(); // メニューは閉じる
          },
          subtitle: Text(myGame.db.getTime()),
        ),
      ],
    );
  }
}
