import 'dart:async';
import 'dart:io';

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
  final RegExp _pattern;

  /// Returns true iff this [RequestMatcher] matches [request].
  bool matches(HttpRequest request) =>
      _pattern.hasMatch(request.uri.path) && request.method == 'POST';

  RequestMatcher(String pattern) : this._pattern = new RegExp(pattern);
}