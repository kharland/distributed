import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:distributed/interfaces/event.dart';
import 'package:distributed/interfaces/node.dart';
import 'package:distributed/interfaces/peer.dart';

/// A filter for incoming connection requests.
///
/// A remote Peer's connection request is valid if it contains the [cookie]
/// accepted by this handler.
///
/// Once a connection is established, This handler tells the remote peer that it
/// is successfully connected and can begin passing messages to this host.
class ConnectionRequestHandler {
  final StreamController<ConnectionEvent> _onConnectionController =
      new StreamController<ConnectionEvent>();

  StreamSubscription _connectionSubscription;
  WebSocket _webSocket;

  ConnectionRequestHandler(String cookie, String hostname,
      [int port = Node.DEFAULT_PORT]) {
    HttpServer.bind(hostname, port).then((HttpServer httpServer) {
      httpServer.listen((HttpRequest request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          _webSocket = await WebSocketTransformer.upgrade(request);
          _connectionSubscription = _webSocket.listen((payload) {
            var request = new _IncomingConnectionRequest(payload);
            if (request.isValid && request.cookie == cookie) {
              _accept(request);
            } else {
              _reject(request);
            }
          }, onError: _webSocket.addError);
        }
      });
    });
  }

  /// Emits when a new [Peer] connection is made.
  Stream<ConnectionEvent> get onConnection => null;

  /// Stops the handler from listening for incoming connections.
  ///
  /// The handler cannot be restarted after calling this. You must create a new
  /// handler to continue accepting new connections.
  Future<Null> close() async {
    await _webSocket.close();
    await _connectionSubscription.cancel();
  }

  // TODO(kjharland): implement
  Future<Null> _reject(_IncomingConnectionRequest request) {}

  // TODO(kjharland): implement
  Future<Null> _accept(_IncomingConnectionRequest request) {}
}

// TODO(kjharland): implement
class ConnectionRequest {}

abstract class _Json {
  static final JsonDecoder _decoder = new JsonDecoder();
  static final JsonEncoder _encoder = new JsonEncoder();

  static Map<String, Object> decode(String json) => _decoder.convert(json);

  static String encode(Map<String, Object> json) => _encoder.convert(json);
}

class _IncomingConnectionRequest {
  static const _INVALID_REQUEST = const _IncomingConnectionRequest.invalid();

  final String cookie;
  final Peer peer;
  final bool _isValid;

  const _IncomingConnectionRequest.invalid()
      : cookie = null,
        peer = null,
        _isValid = false;

  const _IncomingConnectionRequest.valid(this.cookie, this.peer)
      : _isValid = true;

  factory _IncomingConnectionRequest(Object payload) {
    if (payload is! String) {
      return _INVALID_REQUEST;
    }

    Map<String, Object> fields = _Json.decode(payload);
    if (fields['cookie'] == null ||
        fields['peer_name'] == null ||
        fields['peer_hostname'] == null ||
        fields['peer_port']) {
      return _INVALID_REQUEST;
    }

    return new _IncomingConnectionRequest.valid(
        fields['cookie'],
        new Peer(fields['peer_name'], fields['peer_hostname'],
            fields['peer_port'], fields['peer_is_hidden'] == true));
  }

  bool get isValid => _isValid;
}
