import 'dart:async';
import 'package:distributed/src/port_mapping_daemon/api/api.dart';
import 'package:distributed/src/port_mapping_daemon/handshake/handshake.dart';
import 'package:distributed/src/port_mapping_daemon/handshake/src/handshake_completer.dart';

abstract class HandshakeImpl extends Handshake {
  final HandshakeCompleter _completer = new HandshakeCompleter();

  DaemonSocket _socket;

  void fail(String reason) {
    _socket.sendHandshakeFailed();
    _completer.fail(reason);
  }

  void succeed(String reason) {
    _socket.sendHandshakeSucceeded();
    _completer.succeed(reason);
  }

  @override
  void start(DaemonSocket socket) {
    _socket = socket;
  }

  @override
  Future<HandshakeResult> get done => _completer.done;
}
