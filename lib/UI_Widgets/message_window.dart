import 'package:flutter/material.dart';

class MessaeWindowWidget extends StatefulWidget {
  const MessaeWindowWidget({super.key});

  @override
  MessaeWindowState createState() => MessaeWindowState();
}

class MessaeWindowState extends State<MessaeWindowWidget> {
  late String message;

  MessaeWindowState() {
    setMessage("あいうえお\nかきくけこ\nさしす\nたち");
  }

  void setMessage(String msg) {
    message = msg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(alignment: Alignment.topLeft, children: <Widget>[
          Positioned(
            top: 0,
            left: 16,
            child: Image.asset(
              "assets/images/window.png",
              height: 136,
              width: 480,
              centerSlice: const Rect.fromLTRB(15, 15, 35, 35),
            ),
          ),
          Positioned(
            top: 12,
            left: 16 + 16,
            child: Text(message,
                style: const TextStyle(
                    color: Colors.white, fontSize: 24, height: 1.1)),
          ),
        ]));
  }
}
