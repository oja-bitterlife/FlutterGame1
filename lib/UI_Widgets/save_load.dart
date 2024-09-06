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
          child: SaveLoadCard(myGame, 1),
        ),
        SimpleDialogOption(
          child: SaveLoadCard(myGame, 2),
        ),
        SimpleDialogOption(
          child: SaveLoadCard(myGame, 3),
        ),
      ],
    );
  }
}

class SaveLoadCard extends StatefulWidget {
  final MyGame myGame;
  final int book;
  const SaveLoadCard(this.myGame, this.book, {super.key});

  @override
  SaveLoadCardState createState() => SaveLoadCardState();
}

class SaveLoadCardState extends State<SaveLoadCard> {
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
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Row(
                children: [
                  const SizedBox(width: 80, height: 80),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(6, 6, 0, 6),
                            child: Row(children: [
                              Text(
                                widget.myGame.userData.getTime(widget.book),
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                "Lv.${widget.myGame.userData.getLevel(widget.book)}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ])),
                        Row(
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrange[300],
                                    foregroundColor: Colors.white),
                                onPressed: () {
                                  widget.myGame.userData.save(widget.book);
                                  setState(() {});
                                },
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
                  )
                ],
              ),
            )));
  }
}
