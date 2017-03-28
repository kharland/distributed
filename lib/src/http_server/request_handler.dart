import 'dart:async';
import 'dart:io';

import 'package:route/url_pattern.dart';

/// Base class for an object that handles [HttpRequest]s.
///
/// [RequestHandler] instances may be chained, so that if a particular handler
/// cannot process a given [HttpRequest], the request is passed on to its
/// successor.
abstract class RequestHandler {
  RequestHandler _successor;

  /// Handles [request].
  ///
  /// The default behavior in this base class implementation is to forward the
  /// request to this handler's successor without taking any action.
  Future handle(HttpRequest request) async {
    if (_successor != null) {
      return _successor.handle(request);
    }
  }

  /// Sets the successor to this [RequestHandler].
  set successor(RequestHandler value) {
    _successor = value;
  }
}

/// An [HttpRequest] filter.
class RequestMatcher {
  /// The pattern for this handler.
  final UrlPattern pattern;

  /// The HTTP method for this handler such as 'GET' or 'POST'.
  final String method;

  /// Returns true iff this [RequestMatcher] matches [request].
  bool matches(HttpRequest request) =>
      pattern.matches(request.uri.path) && request.method == method;

  RequestMatcher(String pattern, this.method)
      : this.pattern = _pattern(pattern);
}

/// Convenience method for creating a [UrlPattern].
UrlPattern _pattern(String pattern) => new UrlPattern(pattern);

const GET = 'GET';
const POST = 'POST';
const DELETE = 'DELETE';
