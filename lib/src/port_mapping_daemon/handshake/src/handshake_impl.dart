import 'dart:async';
import 'package:distributed/src/port_mapping_daemon/handshake/handshake.dart';
import 'package:distributed/src/port_mapping_daemon/handshake/src/handshake_completer.dart';

abstract class HandshakeImpl extends Handshake {
  final HandshakeCompleter _completer = new HandshakeCompleter();

  void fail(String reason) {
    _completer.fail(reason);
  }

  void succeed(String reason) {
    _completer.succeed(reason);
  }

  @override
  Future<HandshakeResult> get failure => _completer.failure;

  @override
  Future<HandshakeResult> get success => _completer.success;
}
