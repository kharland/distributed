import 'dart:async';

import 'package:distributed.http/src/configuration.dart';
import 'package:meta/meta.dart';

class Http {
  /// Sends a GET request to [url].
  Future<HttpResponse> get(String url) => http.get(url);

  /// Sends a POST request to [url].
  Future<HttpResponse> post(String url, {String payload}) =>
      http.post(url, payload: payload);

  /// Sends a DELETE request to [url].
  Future<HttpResponse> delete(String url) => http.delete(url);
}

class HttpWithTimeout implements Http {
  @visibleForTesting
  static const TIMEOUT_DURATION = const Duration(milliseconds: 200);
  final Http _delegate;

  HttpWithTimeout(this._delegate);

  @override
  Future<HttpResponse> get(String url) =>
      _delegate.get(url).timeout(TIMEOUT_DURATION);

  @override
  Future<HttpResponse> post(String url, {String payload}) =>
      _delegate.post(url, payload: payload).timeout(TIMEOUT_DURATION);

  @override
  Future<HttpResponse> delete(String url) =>
      _delegate.delete(url).timeout(TIMEOUT_DURATION);
}

abstract class HttpRequest implements Stream<String> {
  /// The method, such as 'GET' or 'POST', for the request.
  String get method;

  /// The URI for the request.
  Uri get uri;
}

/// The response to an [HttpRequest].
abstract class HttpResponse implements Stream<String> {}
