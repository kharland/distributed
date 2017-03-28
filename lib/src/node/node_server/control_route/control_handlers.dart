import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:distributed/distributed.dart';
import 'package:distributed/src/http_server/request_handler.dart';
import 'package:route/server.dart';

/// Forces a connection between a given [Node] and [Peer].
///
/// The [Peer] comes from the [HttpRequest] handled by this [RequestHandler].
class ConnectHandler extends PatternBasedHandler {
  final Node _node;

  ConnectHandler(this._node);

  @override
  String get method => 'POST';

  @override
  UrlPattern get pattern => new UrlPattern(r'/connect/[a-z0-9]+');

  /// Forces a connection to the peer specified in [request].
  ///
  /// If [request] does not contain a peer, an [ArgumentError] is thrown.  If
  /// the connection fails, an [Exception] is raised.
  @override
  Future handle(HttpRequest request) async {
    var peerString = await _readAsString(request);
    var peer = Peer.deserialize(peerString);
    if (!await _node.connect(peer)) {
      throw new Exception('Connection failed');
    }
  }
}

/// Forces a disconnection between a given [Node] and [Peer].
///
/// The [Peer] comes from the [HttpRequest] handled by this [RequestHandler].
class DisconnectHandler extends PatternBasedHandler {
  final Node _node;

  DisconnectHandler(this._node);

  @override
  String get method => 'DELETE';

  @override
  UrlPattern get pattern => new UrlPattern(r'/connect/[a-z0-9]+');

  /// Forces a disconnection to the peer specified in [request].
  ///
  /// If [request] does not contain a peer, an [ArgumentError] is thrown.  If
  /// the disconnection fails, an [Exception] is raised.
  @override
  Future handle(HttpRequest request) async {
    var peerString = await _readAsString(request);
    var peer = Peer.deserialize(peerString);
    _node.disconnect(peer);
    await _node.onDisconnect.take(1).first;
  }
}

// TODO: Catch deserialization error.
Future<String> _readAsString(HttpRequest request) => request
    .transform(new Utf8Decoder())
    .fold('', (encoded, next) => '$encoded$next');
