import 'dart:async';
import 'package:console/console.dart' show Cursor;
import 'package:distributed/src/user_input/keyboard.dart';

/// Executes actions on an [InputEditor] according to data recieved on some
/// input stream.
class InputEditorControls {
  final InputEditor _editor;
  final Keyboard _keyboard = new Keyboard();
  final List<StreamSubscription> _subscriptions = <StreamSubscription>[];

  InputEditorControls(this._editor);

  /// Attaches Keyboard listeners and callbacks for the given [InputEditor].
  void enable(Stream<List<int>> input) {
    _keyboard.activate(input);
    _subscriptions.addAll([
      _keyboard.onKeySet(KeySet.visible).listen((String value) {
        _editor.write(value);
      }),
      _keyboard.onKey(Key.space).listen((String value) {
        _editor.write(value);
      }),
      _keyboard.onKey(Key.enter).listen((_) {
        _editor.write('\n');
      }),
      _keyboard.onKey(Key.del).listen((_) {
        _editor.backspace();
      }),
      _keyboard.onKey(Key.left).listen((_) {
        _editor.cursorLeft();
      }),
      _keyboard.onKey(Key.right).listen((_) {
        _editor.cursorRight();
      })
    ]);
  }

  /// Disables [Keyboard] handlers. Do not forget to call this.
  void disable() {
    _subscriptions.forEach((s) => s.cancel());
    _keyboard?.deactivate();
  }
}

/// Used to control cursor movement and keyboard capture.
class InputEditor {
  final StreamController<String> _onLineController =
      new StreamController<String>();
  final Cursor _cursor = new Cursor();
  final String _prompt;
  String _value = '';

  InputEditor({String prompt: '> '}) : _prompt = prompt {
    _cursor.show();
  }

  Stream<String> get lines => _onLineController.stream;

  void prompt() {
    _cursor.write(_prompt);
  }

  /// Write a single character to the editor.
  void put(int codeUnit) {
    var val = _value;
    var char = new String.fromCharCode(codeUnit);

    if ('\n' == char) {
      _onLineController.add(_value);
      _value = '';
      _cursor.write(char);
      prompt();
    } else if (val.isEmpty) {
      _value = char;
      _cursor.write(char);
    } else {
      var column = _cursor.position.column - _column0;
      if (column >= _value.length) {
        _value = '$_value$char';
        _cursor.write(char);
      } else {
        var prefix = val.substring(0, column);
        var suffix = val.substring(column);
        _value = '$prefix$char$suffix';
        _cursor
          ..writeAt(_column0 + column, _cursor.position.row, '$char$suffix')
          ..move(_column0 + column + 1, _cursor.position.row);
      }
    }
  }

  void write(String value) {
    value.codeUnits.forEach(put);
  }

  void backspace() {
    var column = _cursor.position.column - _column0;
    if (column > 0) {
      int previousLength = _value.length;
      var prefix = _value.substring(0, column - 1);
      var suffix = _value.substring(column);
      _value = '$prefix$suffix';
      _cursor
        ..move(_column0, _cursor.position.row)
        ..write(_value.padRight(previousLength))
        ..move(_column0 + column - 1, _cursor.position.row);
    }
  }

  void cursorLeft() {
    if (_cursor.position.column > _column0) {
      _cursor.moveLeft();
    }
  }

  void cursorRight() {
    if (_cursor.position.column < _prompt.length + _value.length + 1) {
      _cursor.moveRight();
    }
  }

  void log(String message) {
    _cursor.move(0, _cursor.position.row);
    _cursor.write('-- $message\n');
    prompt();
    if (_value.isNotEmpty) {
      write(_value);
    }
  }

  int get _column0 => _prompt.length + 1;
}
