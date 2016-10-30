import 'dart:async';

import 'package:distributed/interfaces/node.dart';
import 'package:distributed/src/io/repl/command.dart';
import 'package:distributed/src/io/repl/repl.dart';

/// A Node that launches an interactive shell and accepts commands.
class NodeREPL {
  final Node _node;
  final _StringSink _errorSink = new _StringSink();
  final _StringSink _logSink = new _StringSink();
  final REPL _repl;
  final List<StreamSubscription> _subscriptions = <StreamSubscription>[];

  CommandRunner _commandRunner;

  NodeREPL(this._node, {String prompt: '> '}) : _repl = new REPL(prompt) {
    _commandRunner = new CommandRunner()
      ..addCommand(new ConnectCommand(_node, _errorSink))
      ..addCommand(new DisconnectCommand(_node, _errorSink))
      ..addCommand(new SendCommand(_node, _errorSink))
      ..addCommand(new ListCommand(_node, _logSink))
      ..addCommand(new QuitCommand(_node));

    _node.onShutdown.then((_) {
      _subscriptions.forEach((s) => s.cancel());
      _repl.stop();
      print('${_node.toPeer().displayName} successfully shut down.');
    });

    _subscriptions.addAll(<StreamSubscription>[
      _errorSink.onMessage.listen(logError),
      _logSink.onMessage.listen(log),
      _node.onConnect.listen((peer) {
        log('connected to ${peer.displayName}');
      }),
      _node.onDisconnect.listen((peer) {
        log('disconnected from ${peer.displayName}');
      }),
      _repl.onInput.listen((String input) {
        var args = input.split(' ').map((s) => s.trim()).toList();
        _commandRunner.parseAndRun(args);
      })
    ]);

    _repl.start();
    log('Node ${_node.name} listening at ${_node.toPeer().url}...');
  }

  void log(String message) {
    _repl.log(message);
  }

  void logError(String message) {
    _repl.log('[Error] $message');
  }
}

class _StringSink implements StringSink {
  StreamController<String> _onMessageController =
      new StreamController<String>();

  Stream<String> get onMessage => _onMessageController.stream;

  @override
  void write(Object obj) {
    _onMessageController.add(obj);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    for (int i = 0; i < objects.length - 1; i++) {
      write('${objects.elementAt(i)}$separator');
    }
    write('${objects.last}');
  }

  @override
  void writeCharCode(int charCode) {
    throw new UnimplementedError();
  }

  @override
  void writeln([Object obj = ""]) {
    throw new UnimplementedError();
  }

  void close() {
    _onMessageController.close();
  }
}
