import 'package:flutter/material.dart';

// ignore: unused_import
import '../my_logger.dart';
import '../Game/my_game.dart';

class SaveLoadDialog extends StatelessWidget {
  final MyGame myGame;
  const SaveLoadDialog(this.myGame, {super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      title: const Text('Save/Load'),
      alignment: Alignment.topLeft,
      children: [
        SimpleDialogOption(
          child: SaveLoadCard(myGame),
        ),
        SimpleDialogOption(
          child: SaveLoadCard(myGame),
        ),
        SimpleDialogOption(
          child: SaveLoadCard(myGame),
        ),
      ],
    );
  }
}

class SaveLoadCard extends StatelessWidget {
  final MyGame myGame;
  const SaveLoadCard(this.myGame, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.lightGreen, width: 2),
        ),
        color: Colors.transparent,
        child: SizedBox(
          height: 80,
          child: Row(
            children: [
              const SizedBox(width: 80, height: 80),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(width: 8),
                        Text(
                          "--/--/-- --:--:--",
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(width: 16),
                        Text(
                          "Lv.0",
                          style: TextStyle(fontSize: 16),
                        ),
                      ]),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange[300],
                              foregroundColor: Colors.white),
                          onPressed: () {},
                          child: const Text("Save")),
                      const SizedBox(width: 4),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue[300],
                              foregroundColor: Colors.white),
                          onPressed: () {},
                          child: const Text("Load"))
                    ],
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
