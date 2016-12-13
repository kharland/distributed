import 'dart:async';

import 'package:distributed/src/port_mapping_daemon/handshake/handshake.dart';

class HandshakeCompleter {
  final _failureCompleter = new Completer<HandshakeResult>();
  final _successCompleter = new Completer<HandshakeResult>();
  final _doneCompleter = new Completer<HandshakeResult>();

  void fail(String reason) {
    var result = new HandshakeResult.error(reason);
    _failureCompleter.complete(reason);
    _doneCompleter.complete(result);
  }

  void succeed(String message) {
    var result = new HandshakeResult(message);
    _successCompleter.complete(result);
    _doneCompleter.complete(result);
  }

  Future<HandshakeResult> get done => _doneCompleter.future;

  Future<HandshakeResult> get failure => _failureCompleter.future;

  Future<HandshakeResult> get success => _successCompleter.future;
}
