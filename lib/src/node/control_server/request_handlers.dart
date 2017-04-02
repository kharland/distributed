import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:distributed/distributed.dart';
import 'package:distributed/src/http_server/request_handler.dart';

/* Default RouteHandler RequestMatchers */

final connectMatcher = new RequestMatcher(r'/connect');
final disconnectMatcher = new RequestMatcher(r'/disconnect');
final pingMatcher = new RequestMatcher(r'/ping');

/// Handles a ping request.
///
/// This handler always sets the reponse status to `HttpStatus.OK` and returns
/// an empty list.
class PingHandler extends RequestHandler {
  final RequestMatcher _matcher;

  PingHandler(this._matcher);

  @override
  Future handle(HttpRequest request) async {
    if (!_matcher.matches(request)) return super.handle(request);
    request
      ..response.statusCode = HttpStatus.OK
      ..response.close();
  }
}

/// Forces a connection between a given [Node] and [Peer].
///
/// The [Peer] comes from the [HttpRequest] handled by this [RequestHandler].
class ConnectHandler extends RequestHandler {
  final Node _node;
  final RequestMatcher _matcher;

  /// Forces a connection to the peer specified in [request].
  ///
  /// If [request] does not contain a peer, an [ArgumentError] is thrown.  If
  /// the connection fails, an [Exception] is raised.
  @override
  Future handle(HttpRequest request) async {
    if (!_matcher.matches(request)) return super.handle(request);
    var peer = Peer.deserialize(await _readAsString(request));
    if (!await _node.connect(peer)) {
      throw new Exception('Connection failed');
    }
    request.response.close();
  }

  ConnectHandler(this._node, this._matcher);
}

/// Forces a disconnection between a given [Node] and [Peer].
///
/// The [Peer] comes from the [HttpRequest] handled by this [RequestHandler].
class DisconnectHandler extends RequestHandler {
  final Node _node;
  final RequestMatcher _matcher;

  /// Forces a disconnection to the peer specified in [request].
  ///
  /// If [request] does not contain a peer, an [ArgumentError] is thrown.  If
  /// the disconnection fails, an [Exception] is raised.
  @override
  Future handle(HttpRequest request) async {
    if (!_matcher.matches(request)) return super.handle(request);
    var peer = Peer.deserialize(await _readAsString(request));
    _node.disconnect(peer);
    await _node.onDisconnect.take(1).first;
    request.response.close();
  }

  DisconnectHandler(this._node, this._matcher);
}

// TODO: Catch deserialization error.
Future<String> _readAsString(HttpRequest request) => request
    .transform(new Utf8Decoder())
    .fold('', (encoded, next) => '$encoded$next');
