import 'dart:async';

import 'package:distributed/src/port_mapping_daemon/api/api.dart';
import 'package:distributed/src/port_mapping_daemon/handshake/handshake.dart';

class HandshakeCompleter {
  final _doneCompleter = new Completer<HandshakeResult>();

  void fail(String reason) {
    var result = new HandshakeResult.error(reason);
    _doneCompleter.complete(result);
  }

  void succeed(String message) {
    var result = new HandshakeResult(message);
    _doneCompleter.complete(result);
  }

  Future<HandshakeResult> get done => _doneCompleter.future;
}
