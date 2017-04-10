import 'dart:async';

import 'package:distributed.http/http.dart';
import 'package:distributed.http/src/configuration.dart';
import 'package:distributed.http/vm.dart';

/// The core of the distributed networking layer.
///
/// This can be completely mocked for testing to circumvent problems like the
/// inability to bind to sockets or open HttpRequests when running on a test
/// server.  This class is intentionally left with a minimal interface because
/// there's no utility in implementing and mocking the various http capabilities
/// that this package doesn't ever use.
abstract class HttpProvider implements Http {
  /// Sends a GET request to [url].
  @override
  Future<HttpResponse> get(String url) => http.get(url);

  /// Sends a POST request to [url].
  @override
  Future<HttpResponse> post(String url, {String payload}) =>
      http.post(url, payload: payload);

  /// Sends a DELETE request to [url].
  @override
  Future<HttpResponse> delete(String url) => http.delete(url);

  /// Binds an http server to [host] on [port].
  ///
  /// Returns a future that completes with the [SocketServer].
  Future<HttpServer> bindHttpServer(String host, int port) =>
      http.bindHttpServer(host, port);

  /// Binds a socket server to [host] on [port].
  ///
  /// This throws an [UnsupportedError] in the browser.
  Future<SocketServer> bindSocketServer(String host, int port) =>
      http.bindSocketServer(host, port);

  /// Binds a socket to [url].
  ///
  /// Returns a [Future] that completes with the [Socket].
  Future<Socket> connectSocket(String url) => http.connectSocket(url);
}
