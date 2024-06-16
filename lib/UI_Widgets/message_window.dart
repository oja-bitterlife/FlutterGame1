import 'package:flutter/material.dart';

class MessaeWindowWidget extends StatefulWidget {
  const MessaeWindowWidget({super.key});

  @override
  MessageWindowState createState() => MessageWindowState();
}

class MessageWindowState extends State<MessaeWindowWidget> {
  String message = ""; // 最初は空(メッセージ無し)

  static const windowX = 16.0;
  static const windowY = 512.0 - 136.0 - 32.0;

  void setMessage(String msg) {
    message = msg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(alignment: Alignment.topLeft, children: <Widget>[
          Positioned(
            top: windowY,
            left: windowX,
            child: Image.asset(
              "assets/images/window.png",
              height: 136,
              width: 480,
              centerSlice: const Rect.fromLTRB(15, 15, 35, 35),
            ),
          ),
          Positioned(
            top: windowY + 12,
            left: windowX + 16,
            child: Text(message,
                style: const TextStyle(
                    color: Colors.white, fontSize: 24, height: 1.1)),
          ),
        ]));
  }
}
