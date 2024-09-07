import 'dart:async';
import 'package:flutter/material.dart';

// ignore: unused_import
import '../my_logger.dart';
import '../Game/my_game.dart';
import '../Game/ui_control.dart';

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
          child: SaveLoadCard(myGame, 0),
        ),
        SimpleDialogOption(
          child: SaveLoadCard(myGame, 1),
        ),
        SimpleDialogOption(
          child: SaveLoadCard(myGame, 2),
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
  //　ボタンの有効無効状態
  bool get canSave => widget.myGame.uiControl.cursor?.isVisible ?? false;
  bool get canLoad => systemData != null;

  // SystemDataキャッシュ
  ({String time, int stage, ImageProvider<Object>? image})? systemData;

  @override
  Widget build(BuildContext context) {
    systemData ??= widget.myGame.userData.getSavedStageData(widget.book, true);

    return Card(
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.lightGreen, width: 2),
        ),
        color: Colors.transparent,
        child: SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
              child: Row(
                children: [
                  getThumbnail(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                            child: Row(children: [
                              Text(
                                getTimeString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                "Stage: ${getStageString()}",
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
                                        // Navigator.of(context).pop(); // メニューは閉じる
                                      },
                                child: const Text("Save")),
                            const SizedBox(width: 4),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue[300],
                                    foregroundColor: Colors.white),
                                onPressed: !canLoad
                                    ? null
                                    : () async {
                                        await onLoad();

                                        // メニューは閉じる
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }
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

  // サムネ部分の表示物
  Widget getThumbnail() {
    if (systemData?.image != null) {
      return Image(image: systemData!.image!, width: 80, height: 80);
    }

    // データが無かったらiconを出しておく
    return const SizedBox(
        width: 80,
        height: 80,
        child:
            Icon(Icons.highlight_off_sharp, size: 64, color: Colors.black26));
  }

  String getTimeString() {
    return (systemData?.time == null) ? "--/--/-- --:--:--" : systemData!.time;
  }

  String getStageString() {
    return (systemData?.stage == null) ? "--" : systemData!.stage.toString();
  }

  void updateSystemData() {
    widget.myGame.userData.getSavedStageData(widget.book, true);
  }

  Future<void> onSave() async {
    // 状態の保存
    await widget.myGame.userData.save(widget.book);

    // セーブデータ表示更新
    setState(() {
      systemData = widget.myGame.userData.getSavedStageData(widget.book, true);
    });
    log.info(systemData);
  }

  Future<void> onLoad() async {
    var stageData =
        widget.myGame.userData.getSavedStageData(widget.book, false);
    if (stageData == null) {
      log.severe("Loadに失敗しました: book=${widget.book}");
      return;
    }

    // 状態の復活
    widget.myGame.reset(stageData.stage);
    await widget.myGame.userData.load(widget.book);

    // UIの復活
    widget.myGame.uiControl.cursor?.visible = true;
    widget.myGame.uiControl.showUI = ShowUI.cursor;
  }
}
