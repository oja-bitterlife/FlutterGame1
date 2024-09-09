import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import '/UI_Widgets/player_cursor.dart';
import '/UI_Widgets/message_window.dart';
import '/UI_Widgets/menu.dart';
import '/Game/my_game.dart';

// ignore: unused_import
import '../my_logger.dart';

Future<void> main() async {
  var myGame = await MyGame.create();
  runApp(MyApp(myGame));
}

class MyApp extends StatelessWidget {
  final MyGame myGame;
  const MyApp(this.myGame, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: myGame.packageInfo.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyGameWidget(myGame),
    );
  }
}

class MyGameWidget extends StatelessWidget {
  final MyGame myGame;
  static ScreenshotController screenshotController = ScreenshotController();
  const MyGameWidget(this.myGame, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        onDrawerChanged: (isOpened) {
          // メニューを出した時Pause、閉じたときresume
          isOpened ? myGame.pause() : myGame.resume();
        },
        appBar: AppBar(
          title: Text("stage: ${myGame.currentStage}"),
        ),
        drawer: Drawer(child: Menu(myGame: myGame)), // menu
        backgroundColor: Colors.black,
        body: SizedBox(
            width: 512,
            height: 512,
            child: Screenshot(
                controller: screenshotController,
                child: Stack(alignment: Alignment.topLeft, children: <Widget>[
                  // GameScreen
                  myGame.createWidget(),
                  // ----------------------------------------------------------------------
                  // ↓ GameUI
                  // メッセージウインドウ
                  MessaeWindowWidget(
                      key: const GlobalObjectKey<MessageWindowState>(
                          "MessageWindow"),
                      myGame: myGame),
                  // アクションカーソル
                  PlayerCursorWidget(
                      key: const GlobalObjectKey<PlayerCursorState>(
                          "PlayerCursor"),
                      myGame: myGame),
                ]))));
  }
}
