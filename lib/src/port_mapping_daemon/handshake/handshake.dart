import 'dart:async';

import 'package:distributed/src/port_mapping_daemon/api/api.dart';
import 'package:distributed/src/port_mapping_daemon/daemon.dart';
import 'package:distributed/src/port_mapping_daemon/handshake/daemon.dart';
import 'package:distributed/src/port_mapping_daemon/handshake/src/handshake_impl.dart';
import 'package:distributed/src/port_mapping_daemon/src/utils.dart';

class HandshakeResult {
  final bool isError;
  final String message;

  HandshakeResult(this.message) : isError = false;

  HandshakeResult.error(this.message) : isError = true;
}

abstract class Handshake {
  void start(DaemonSocket socket);

  Future<HandshakeResult> get failure;

  Future<HandshakeResult> get success;
}

Handshake receiveHandshake(PortMappingDaemon daemon) =>
    new _InitiatingHandshake(daemon);

class _InitiatingHandshake extends HandshakeImpl {
  final PortMappingDaemon _daemon;

  _InitiatingHandshake(this._daemon);

  @override
  void start(DaemonSocket socket) {
    wait(socket.stream, 1)
      ..timeout.then((_) {

      })
      ..data.then((_) {

      });

    nextElement(socket.stream, onTimeout: () {
      fail('Timed out');
    }, onData: (String payload) {
      Handshake delegate;

      if (!Entity.canParseAs(RequestInitiation, payload)) {
        fail('Invalid message');
        return;
      }

      var request = new RequestInitiation.fromString(payload);
      if (request.cookie != _daemon.cookie) {
        fail('Invalid cookie');
        return;
      }

      switch (request.type) {
        case RequestType.ping:
          delegate = new PingHandshake();
          break;
        case RequestType.register:
          delegate = new RegisterNodeHandshake(_daemon);
          break;
        case RequestType.deregister:
        case RequestType.connect:
        case RequestType.list:
          throw new UnimplementedError();
        default:
          throw new UnimplementedError(request.type.toString());
      }

      delegate.start(socket);
    });
  }
}
