import 'dart:async';

import 'package:distributed/distributed.dart';
import 'package:distributed/src/http_server_builder/request_handler.dart';
import 'package:distributed/src/node/remote_control/node_command.dart';
import 'package:distributed.http/vm.dart';

/* Default RouteHandler RequestMatchers */

final connectMatcher = new RequestMatcher(r'/connect');
final disconnectMatcher = new RequestMatcher(r'/disconnect');

/// Handles requests to connect one node to another
class ConnectHandler extends RequestHandler {
  final RequestMatcher _matcher;
  final Sink<NodeCommand> _commandSink;

  ConnectHandler(this._matcher, this._commandSink);

  @override
  Future handle(ServerHttpRequest request) async {
    if (!_matcher.matches(request)) return super.handle(request);
    _commandSink.add(new ConnectCommand(Peer.deserialize(await request.first)));
  }
}

/// Handles requests to disconnect one node from another.
class DisconnectHandler extends RequestHandler {
  final RequestMatcher _matcher;
  final Sink<NodeCommand> _commandSink;

  DisconnectHandler(this._matcher, this._commandSink);

  @override
  Future handle(ServerHttpRequest request) async {
    if (!_matcher.matches(request)) return super.handle(request);
    _commandSink
        .add(new DisconnectCommand(Peer.deserialize(await request.first)));
  }
}
