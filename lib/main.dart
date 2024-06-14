import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'my_game.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyGameWidget(),
    );
  }
}

const windowX = 16.0;
const windowY = 512.0 - 136.0 - 32.0;

class MyGameWidget extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(alignment: Alignment.topLeft, children: <Widget>[
      GameWidget(game: MyGame()),
      Positioned(
        top: windowY,
        left: windowX,
        child: Image.asset(
          "images/window.png",
          height: 136,
          width: 480,
          centerSlice: Rect.fromLTRB(15, 15, 35, 35),
        ),
      ),
    ]));
  }
}
