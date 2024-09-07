import 'package:flutter/material.dart';
import 'package:my_app/UI_Widgets/player_cursor.dart';
import 'package:screenshot/screenshot.dart';
import 'Game/my_game.dart';
import 'UI_Widgets/message_window.dart';
import 'UI_Widgets/menu.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(await PackageInfo.fromPlatform()));
}

class MyApp extends StatelessWidget {
  final PackageInfo packageInfo;
  const MyApp(this.packageInfo, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyGameWidget(MyGame(), packageInfo),
    );
  }
}

class MyGameWidget extends StatelessWidget {
  final PackageInfo packageInfo;

  final MyGame myGame;
  static ScreenshotController screenshotController = ScreenshotController();
  const MyGameWidget(this.myGame, this.packageInfo, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(packageInfo.appName),
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
