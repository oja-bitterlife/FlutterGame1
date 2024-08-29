import 'dart:math';

import 'package:flutter/material.dart';

// ignore: unused_import
import '../my_logger.dart';
import '../Game/my_game.dart';

class MessaeWindowWidget extends StatefulWidget {
  final MyGame myGame;
  const MessaeWindowWidget({super.key, required this.myGame});

  @override
  MessageWindowState createState() => MessageWindowState();
}

class MessageWindowState extends State<MessaeWindowWidget> {
  String _message = ""; // 最初は空(メッセージ無し)
  bool _isVisible = false;

  // メッセージ文字列設定
  static const int autoCRLength = 18; // 自動改行される文字数
  static const double fontSize = 24; // フォントサイズ

  // ウインドウ位置定義
  static const windowW = 480.0;
  static const windowH = 136.0;
  static const windowX = 16.0;
  static const windowY = 512.0 - windowH - 32.0;

  // メッセージ表示
  void show(String msg, {bool isAutoCR = true}) {
    // 自動改行(autoCRが0の時は改行しない)
    if (autoCRLength > 0 && isAutoCR) {
      List<String> parts = [];
      for (int i = 0; i * autoCRLength < msg.length; i++) {
        parts.add(msg.substring(
            i * autoCRLength, min(msg.length, (i + 1) * autoCRLength)));
      }
      msg = parts.join("\n");
    }

    // 表示開始
    setState(() {
      _message = msg;
      _isVisible = true;
    });
  }

  // メッセージ非表示
  void hide() {
    setState(() {
      _isVisible = false;
    });
  }

  // メッセージ状態取得
  bool get isVisible => _isVisible;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: _isVisible,
        // 9-patchウインドウ
        child: GestureDetector(
            onTap: () {
              onScreenTap();
            },
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(alignment: Alignment.topLeft, children: <Widget>[
                  Positioned(
                    top: windowY,
                    left: windowX,
                    child: Image.asset(
                      "assets/images/window.png",
                      width: windowW,
                      height: windowH,
                      centerSlice: const Rect.fromLTRB(15, 15, 35, 35),
                    ),
                  ),
                  // テキスト
                  Positioned(
                    top: windowY + 16,
                    left: windowX + 16,
                    child: Text(_message,
                        style: const TextStyle(
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                            fontSize: fontSize,
                            height: 1.1)),
                  ),
                ]))));
  }

  // メッセージウインドウ表示中に画面がタップされた時の処理
  void onScreenTap() {
    // widget.myGame.eventManager.onMsgTap();
  }
}
