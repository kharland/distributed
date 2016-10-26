import 'dart:async';
import 'dart:convert';
import 'dart:io';

class REPL {
  static const String _prefix = '>> ';

  final String prefix;
  StreamController<String> _onInputController = new StreamController<String>();
  StreamSubscription<String> _stdinSubscription;
  String _currentBuffer = _prefix;

  REPL({void printWelcome(), this.prefix: _prefix}) {
    stdin.lineMode = false;
    _currentBuffer = prefix;
    _stdinSubscription =
        stdin.transform(new AsciiDecoder()).listen((String char) {
      if (char == '\n') {
        _onInputController.add(_currentBuffer.substring(prefix.length).trim());
        _currentBuffer = prefix;
      } else {
        _currentBuffer += char;
        stdout.write('\r$_currentBuffer');
      }
    });
    if (printWelcome != null) {
      printWelcome();
    }
    stdout.write(prefix);
  }

  void log(String message) {
    stdout.write('\r$message\n');
    stdout.write(_currentBuffer);
  }

  void kill() {
    _onInputController.close();
    _stdinSubscription.cancel();
  }

  Stream<String> get onInput => _onInputController.stream;
}
