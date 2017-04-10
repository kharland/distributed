import 'dart:async';

import 'package:distributed.http/http.dart';
import 'package:distributed/distributed.dart';
import 'package:distributed/src/http_server_builder/request_handler.dart';
import 'package:distributed.http/vm.dart';

/* Default RouteHandler RequestMatchers */

final connectMatcher = new RequestMatcher(r'/connect');
final disconnectMatcher = new RequestMatcher(r'/disconnect');

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
  Future handle(ServerHttpRequest request) async {
    if (!_matcher.matches(request)) return super.handle(request);
    var peer = Peer.deserialize(await request.first);
    if (!await _node.connect(peer)) {
      throw new Exception('Connection failed');
    }
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
  Future handle(ServerHttpRequest request) async {
    if (!_matcher.matches(request)) return super.handle(request);
    var peer = Peer.deserialize(await request.first);
    _node.disconnect(peer);
    await _node.onDisconnect.take(1).first;
  }

  DisconnectHandler(this._node, this._matcher);
}
