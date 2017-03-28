import 'dart:async';
import 'dart:io';

import 'package:distributed/distributed.dart';
import 'package:distributed/src/http_server/request_handler.dart';
import 'package:distributed/src/http_server/route.dart';

/// A [Route] that controls a [Node].
///
/// This route can be used to shutdown the node, force a connection, force a
/// disconnection, etc.  `sendToHandler` will always return false for this route
/// when a [RequestHandler] is found for a request.
class ControlRoute implements Route {
  final List<RequestHandler> _handlers;

  ControlRoute(this._handlers);

  @override
  bool accepts(HttpRequest request) => request.uri.path.startsWith('/control');

  @override
  Future<bool> sendToHandler(HttpRequest request) async {
    var handler = _handlers.firstWhere(_canHandle(request), orElse: () => null);
    if (handler != null) {
      await handler.handle(request);
    }
    return false;
  }

  // ignore: always_declare_return_types
  _canHandle(HttpRequest request) => (handler) => handler.canHandle(request);
}
