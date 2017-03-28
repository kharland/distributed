import 'dart:async';
import 'dart:io';

import 'package:distributed/src/http_server/request_handler.dart';
import 'package:distributed/src/http_server/router.dart';

/// An object that selectively forwards an [HttpRequest] to a [RequestHandler].
///
/// A [Route] may have several [RequestHandler]s, but only one is executed per
/// [HttpRequest].
abstract class Route {
  /// Returns true iff this [Route] can process [request].
  bool accepts(HttpRequest request);

  /// Forwards [request] to the appropriate [RequestHandler].
  ///
  /// If `accepts([request])` returns false, an [ArgumentError] is thrown.  If
  /// the returned future completes with true, it is ok for a the [Router]
  /// invoking this [Route] to forward [request] to the next [Route].
  Future<bool> sendToHandler(HttpRequest request);
}
