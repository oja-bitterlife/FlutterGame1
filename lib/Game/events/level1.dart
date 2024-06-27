class MessageEvent {
  int index = 0;
  final msg = ["宝箱の中には扉の鍵が入っていた"];

  String getMsg() {
    return msg[index];
  }

  void next() {
    index += 1;
  }
}

class Level1Data {
  final event = MessageEvent();
  // "callback": "getDoorKey"
  // };
}
