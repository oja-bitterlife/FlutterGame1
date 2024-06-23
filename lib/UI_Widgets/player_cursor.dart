import 'package:flutter/material.dart';

class PlayerCursorWidget extends StatefulWidget {
  const PlayerCursorWidget({super.key});

  @override
  PlayerCursorState createState() => PlayerCursorState();
}

class PlayerCursorState extends State<PlayerCursorWidget> {
  @override
  Widget build(BuildContext context) {
    return const Visibility(
        visible: true,
        child: Icon(Icons.arrow_back, textDirection: TextDirection.ltr));
  }
}
