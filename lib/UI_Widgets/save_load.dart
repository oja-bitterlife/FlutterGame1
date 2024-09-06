import 'dart:async';
import 'dart:typed_data';
import "dart:ui" as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: unused_import
import '../my_logger.dart';
import '../Game/my_game.dart';
import '../Game/ui_control.dart';
import '../main.dart';

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
  //　セーブボタンの有効無効状態
  bool get canSave => widget.myGame.uiControl.cursor?.isVisible ?? false;

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
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Image(
                      image:
                          widget.myGame.userData.thumbnails[widget.book - 1]),
                  // const SizedBox(width: 80, height: 80), // サムネイル
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
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
                                onPressed: !canSave
                                    ? null
                                    : () async {
                                        // セーブ可能状態の時だけ有効に
                                        await onSave();
                                        setState(() {});
                                        // Navigator.of(context).pop(); // メニューは閉じる
                                      },
                                child: const Text("Save")),
                            const SizedBox(width: 4),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue[300],
                                    foregroundColor: Colors.white),
                                onPressed: () {
                                  onLoad();
                                  Navigator.of(context).pop(); // メニューは閉じる
                                },
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

  Future<void> onSave() async {
    var bytes = await MyGameWidget.screenshotController.capture();
    if (bytes != null) {
      widget.myGame.userData.thumbnails[widget.book - 1] = MemoryImage(bytes);
    }
    widget.myGame.userData.save(widget.book);
  }

  void onLoad() {
    int level = widget.myGame.userData.getLevel(widget.book) ?? 0;

    // 状態の復活
    widget.myGame.reset(level);
    widget.myGame.userData.load(widget.book);

    // UIの復活
    widget.myGame.uiControl.cursor?.visible = true;
    widget.myGame.uiControl.showUI = ShowUI.cursor;
  }
}
