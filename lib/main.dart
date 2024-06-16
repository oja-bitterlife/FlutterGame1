import 'package:flutter/material.dart';
import 'Game/GameMain.dart';
import 'UI_Widgets/MessageWindow.dart';

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
      home: const MyGameWidget(),
    );
  }
}

class MyGameWidget extends StatelessWidget {
  const MyGameWidget({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(alignment: Alignment.topLeft, children: <Widget>[
      MyGame().getWidget(), // GameScreen
      const MessaeWindowWidget(), // GameUI
    ]));
  }
}
