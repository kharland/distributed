import 'dart:async';

import 'package:distributed.http/http.dart';
import 'package:distributed.http/vm.dart';
import 'package:distributed/src/http_server_builder/request_template.dart';

/// The callback executed by a [RequestHandler].
typedef Future HandlerCallback(
    ServerHttpRequest request, Map<String, String> args);

/* Shorthand methods for creating [RequestHandler] instances. */

RequestHandler any(String template, HandlerCallback callback) =>
    new RequestHandler.anyMethod(new RequestTemplate(template), callback);

RequestHandler get(String template, HandlerCallback callback) =>
    new RequestHandler.get(new RequestTemplate(template), callback);

RequestHandler post(String template, HandlerCallback callback) =>
    new RequestHandler.post(new RequestTemplate(template), callback);

RequestHandler delete(String template, HandlerCallback callback) =>
    new RequestHandler.delete(new RequestTemplate(template), callback);

/// Base class for an object that handles [HttpRequest]s.
///
/// [RequestHandler] instances may be chained, so that if a particular handler
/// cannot process a given [HttpRequest], the request is passed on to its
/// successor.
class RequestHandler {
  final HandlerCallback _callback;
  final RequestTemplate _template;
  final String _method;
  RequestHandler _successor;

  /// Creates a handler for a GET request.
  RequestHandler.get(this._template, this._callback) : _method = 'GET';

  /// Creates a handler for a POST request.
  RequestHandler.post(this._template, this._callback) : _method = 'POST';

  /// Creates a handler for a DELETE request.
  RequestHandler.delete(this._template, this._callback) : _method = 'DELETE';

  /// Creates a handler that ignores the request method.
  RequestHandler.anyMethod(this._template, this._callback) : _method = '';

  /// Handles [request].
  ///
  /// The default behavior in this base class implementation is to forward the
  /// request to this handler's successor without taking any action.
  Future handle(ServerHttpRequest request) {
    var requestPath = request.uri.path;
    return _template.matches(requestPath) &&
            (_method.isEmpty || request.method == _method)
        ? _callback(request, _template.parseArguments(requestPath))
        : _successor?.handle(request);
  }

  /// Sets the successor to this [RequestHandler].
  set successor(RequestHandler value) {
    _successor = value;
  }
}
