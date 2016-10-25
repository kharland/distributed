import 'dart:async';
import 'dart:convert';
import 'dart:io';

class REPL {
  static const String _bufferInit = '>> ';

  StreamController<String> _onInputController = new StreamController<String>();
  StreamSubscription<String> _stdinSubscription;
  String _buffer = _bufferInit;

  REPL(void printWelcome(String prompt)) {
    stdin.lineMode = false;
    _stdinSubscription =
        stdin.transform(new Utf8Decoder()).listen((String char) {
      if (char == '\n') {
        _onInputController.add(_buffer.substring(_bufferInit.length).trim());
        _buffer = _bufferInit;
      } else {
        _buffer += char;
      }
    });

    printWelcome(_bufferInit);
  }

  void log(String message) {
    stdout.write('\r$message\n');
    stdout.write(_buffer);
  }

  void kill() {
    _onInputController.close();
    _stdinSubscription.cancel();
  }

  Stream<String> get onInput => _onInputController.stream;
}
