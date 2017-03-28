import 'dart:async';
import 'dart:io';
import 'package:distributed/src/http_server/route.dart';

/// Routes an [HttpRequest] to one or more [Route]s.
///
/// When a request is received, each [Route] is considered to process the
/// request in the order that it was registered.  For example if a [Router] was
/// created with the following routes:
///
///   FooRoute, BarRoute, BazRoute
///
/// FooRoute will always be checked first to see whether it accepts the request,
/// followed by BarRoute and BazRoute.
class Router {
  final List<Route> _routes;

  /// Routes [request] to this [Router]'s registered [Route]s.
  ///
  /// If no [Route] can handle [request], the response status is set to
  /// `HttpStatus.NOT_FOUND` and the connection is closed.
  Future route(HttpRequest request) async {
    var it = _routes.where((route) => route.accepts(request)).iterator;
    while (it.moveNext() && await it.current.sendToHandler(request));
  }

  /// Creates a [Router] with the given [Route]s.
  Router.fromRoutes(List<Route> routes)
      : _routes = new List.unmodifiable(routes);
}
