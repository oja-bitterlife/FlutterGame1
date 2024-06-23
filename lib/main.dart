import 'package:flutter/material.dart';
import 'package:my_app/UI_Widgets/player_cursor.dart';
import 'Game/my_game.dart';
import 'UI_Widgets/message_window.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyGameWidget(myGame: MyGame()),
    );
  }
}

class MyGameWidget extends StatelessWidget {
  final MyGame myGame;
  const MyGameWidget({super.key, required this.myGame});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.topLeft, children: <Widget>[
      // GameScreen
      myGame.createWidget(),
      // ----------------------------------------------------------------------
      // ↓ GameUI
      // メッセージウインドウ
      IgnorePointer(
          // クリックを奪わないように
          child: MessaeWindowWidget(
              key: const GlobalObjectKey<MessageWindowState>("MessageWindow"),
              myGame: myGame)),
      // アクションカーソル
      PlayerCursorWidget(
          key: const GlobalObjectKey<PlayerCursorState>("PlayerCursor"),
          myGame: myGame),
    ]);
  }
}
