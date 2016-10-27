import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';

class REPL {
  final _LineEditor _editor;
  StreamSubscription<String> _editorSubscription;

  REPL({String startupMessage: '', String prefix: '>> '})
      : _editor = new _LineEditor(stdin, prefix) {
    stdout.write(startupMessage);
    _editorSubscription = _editor.onInput.listen((_) {
      stdout.writeln();
    });
  }

  Stream<String> get onInput => _editor.onInput;

  void log(String message) {
    stdout.writeln('\r$message');
    stdout.write(_editor.currentBuffer);
  }

  void stop() {
    _editorSubscription.cancel();
    _editor.close();
  }
}

class _LineEditor {
  static final _listeq = const ListEquality().equals;
  static const _backspace = const [127];
  static const _up = const [27, 91, 65];
  static const _down = const [27, 91, 66];
  static const _prefix = '> ';

  final Stdin _stdin;
  final String prefix;

  int _bufferCachePos = 0;
  List<String> _bufferCache;
  StreamController<String> _onInputController =
      new StreamController<String>.broadcast();
  StreamSubscription<String> _stdinSubscription;

  _LineEditor(this._stdin, [this.prefix = _prefix]) {
    _stdin.echoMode = false;
    _stdin.lineMode = false;
    _bufferCache = <String>[prefix];
    _stdinSubscription =
        _stdin.transform(new AsciiDecoder()).listen((String char) {
      if (char == '\n') {
        _onInputController.add(_buffer.substring(prefix.length).trim());
        _bufferCache.add(prefix);
        _bufferCachePos++;
      } else if (_listeq(char.codeUnits, _backspace)) {
        if (_buffer.length > prefix.length) {
          _buffer = _buffer.substring(0, _buffer.length - 1);
        }
      } else if (_listeq(char.codeUnits, _up) && _bufferCachePos > 0) {
        _bufferCachePos--;
      } else if (_listeq(char.codeUnits, _down) &&
          _bufferCachePos < _bufferCache.length - 1) {
        _bufferCachePos++;
      } else {
        _buffer += char;
      }
      // clear current line.
      stdout.write('\r${' ' * _buffer.length}');
      stdout.write('\r$_buffer');
    });
  }

  String get currentBuffer => _buffer;

  Stream<String> get onInput => _onInputController.stream;

  String get _buffer => _bufferCache[_bufferCachePos];

  set _buffer(String value) {
    _bufferCache[_bufferCachePos] = value;
  }

  void close() {
    _onInputController.close();
    _stdinSubscription.cancel();
    _stdin.echoMode = true;
    _stdin.lineMode = true;
  }
}
