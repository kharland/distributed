import 'dart:async';
import 'dart:io';

import 'package:distributed/src/user_input/editor.dart';

/// Read-Eval-Print loop used by an [InteractiveNode].
///
/// The [REPL] disables the echo and line modes of stdin. The client should
/// call [close] when finished to avoid hanging and misconfiguration of the
/// the shell.
///
/// On Mac/Linux, terminal after-effects can be fixed using the shell utility
/// `reset`.
class REPL {
  static final _StreamSplitter<List<int>> _streamSplitter =
      new _StreamSplitter<List<int>>(stdin);
  InputEditorControls _editorControls;
  InputEditor _editor;

  /// Creates and starts [REPL] with the given prompt/
  REPL([String prompt = '> ']) : _editor = new InputEditor(prompt: prompt);

  /// Stream of user-input lines.
  Stream<String> get onInput => _editor.lines;

  /// Launches the CLI Read-Eval-Print loop.
  ///
  /// Do not forget to call [stop] after calling [start] when you are finished.
  void start() {
    stdin.echoMode = false;
    stdin.lineMode = false;
    _editorControls?.disable();
    _editorControls = new InputEditorControls(_editor);
    _editorControls.enable(_streamSplitter.stream);
    _editor.prompt();
  }

  /// Stops the loop and restores stdin.
  void stop() {
    stdin.echoMode = true;
    stdin.lineMode = true;
    _streamSplitter.close();
    _editorControls?.disable();
  }

  /// Log a message in this [REPL].
  ///
  /// Unlike a normal shell, the message is logged above the user's input to
  /// preserve the current input buffer.
  void log(String message) {
    _editor.log(message);
  }
}

/// Converts a single subscription stream into a broadcast stream.
///
/// Unlike a broadcast stream created using [Stream.asBroadcastStream] The
/// original [StreamSubscription] can be cancelled via [_StreamSplitter.close].
class _StreamSplitter<T> {
  final StreamController<T> _outStream;
  StreamSubscription<T> _streamSub;

  _StreamSplitter(Stream<T> stream)
      : _outStream = new StreamController<T>.broadcast() {
    _streamSub = stream.listen(_outStream.add);
  }

  Stream<T> get stream => _outStream.stream;

  void close() {
    _streamSub.cancel();
  }
}
