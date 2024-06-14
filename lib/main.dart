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

class MyGameWidget extends StatelessWidget {
  const MyGameWidget({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(alignment: Alignment.topLeft, children: <Widget>[
      GameWidget(game: MyGame()),
      Positioned(
        top: 512 - 136 - 32,
        left: 16,
        child: Image.asset(
          "images/window.png",
          height: 136,
          width: 480,
          centerSlice: const Rect.fromLTRB(15, 15, 35, 35),
        ),
      ),
      const Positioned(
        top: 512 - 136 - 32 + 12,
        left: 16 + 16,
        child: Text("あいうえお\nかきくけこ\nさしす\nたち",
            style: TextStyle(color: Colors.white, fontSize: 24, height: 1.1)),
      ),
    ]));
  }
}
