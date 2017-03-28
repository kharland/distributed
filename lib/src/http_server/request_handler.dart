import 'dart:async';
import 'dart:io';

import 'package:route/url_pattern.dart';

/// An object that handles [HttpRequest]s.
abstract class RequestHandler {
  /// Returns true iff this [RequestHandler] can handle [request].
  bool canHandle(HttpRequest request);

  /// Handles [request].
  Future handle(HttpRequest request);
}

/// A [RequestHandler] that corresponds to a request [pattern].
abstract class PatternBasedHandler implements RequestHandler {
  /// The pattern for this handler.
  UrlPattern get pattern;

  /// The HTTP method for this handler such as 'GET' or 'POST'.
  String get method;

  @override
  bool canHandle(HttpRequest request) =>
      pattern.matches(request.uri.path) && request.method == method;
}
