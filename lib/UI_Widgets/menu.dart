import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import '../Game/ui_control.dart';

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
            myGame.event.add(myGame.event.createFromDB("on_start"));
            Navigator.of(context).pop(); // メニューは閉じる
          },
        ),
        ListTile(
          title: const Text('Save'),
          onTap: () {
            myGame.userData.save(1);
            Navigator.of(context).pop(); // メニューは閉じる
          },
        ),
        ListTile(
          title: const Text('Load'),
          onTap: () {
            if (myGame.userData.hasSave(1)) {
              myGame.reset();
              myGame.userData.load(1);
              myGame.uiControl.cursor?.visible = true;
              myGame.uiControl.showUI = ShowUI.cursor;
            }
            Navigator.of(context).pop(); // メニューは閉じる
          },
          subtitle: Text(myGame.userData.getTime(1)),
        ),
        ListTile(
            title: const Text('Save/Load'),
            onTap: () async {
              Navigator.of(context).pop(); // メニューは閉じる

              await showDialog(
                  context: context,
                  builder: (context) {
                    return const SaveLoadDialog();
                  });
            }),
      ],
    );
  }
}

class SaveLoadDialog extends StatelessWidget {
  const SaveLoadDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      title: Text('Save/Load'),
      alignment: Alignment.topLeft,
      children: [
        SimpleDialogOption(
          child: SaveLoadCard(),
        ),
        SimpleDialogOption(
          child: SaveLoadCard(),
        )
      ],
    );
  }
}

class SaveLoadCard extends StatelessWidget {
  const SaveLoadCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.lightGreen, width: 2),
      ),
      color: Colors.transparent,
      child: Row(
        children: [
          Text("Image"),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "--/--/-- --:--:--",
                style: TextStyle(fontSize: 20),
              ),
              Row(
                children: [
                  ElevatedButton(onPressed: () {}, child: const Text("Save")),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue),
                      onPressed: () {},
                      child: const Text("Load"))
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
