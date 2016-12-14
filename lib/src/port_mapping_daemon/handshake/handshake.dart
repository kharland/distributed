import 'dart:async';

import 'package:distributed/src/port_mapping_daemon/api/api.dart';
import 'package:distributed/src/port_mapping_daemon/daemon.dart';
import 'package:distributed/src/port_mapping_daemon/handshake/daemon.dart';
import 'package:distributed/src/port_mapping_daemon/handshake/src/handshake_impl.dart';

abstract class Handshake {
  void start(DaemonSocket socket);

  Future<HandshakeResult> get done;
}

Handshake receiveHandshake(PortMappingDaemon daemon) =>
    new _InitiatingHandshake(daemon);

class _InitiatingHandshake extends HandshakeImpl {
  final PortMappingDaemon _daemon;
  StreamSubscription<String> _subscription;

  _InitiatingHandshake(this._daemon);

  @override
  void start(DaemonSocket socket) {
    _subscription = socket.stream.listen((String payload) {
      _subscription.cancel();
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
