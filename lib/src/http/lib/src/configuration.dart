import 'dart:async';

import 'package:distributed.http/vm.dart';

/// The singleton [HttpProvider] for the current isolate.
///
/// This must be set exactly once via [initializeHttp] before invoking any HTTP
/// related methods.
HttpProvider http;

/// Sets [http] for the current isolate.
///
/// This must be called exactly once before using this library.
void initializeHttp(HttpProvider provider) {
  assert(http == null, 'http is already initialized!');
  http = provider;
}

/// The core of the distributed networking layer.
///
/// This can be completely mocked for testing to circumvent problems like the
/// inability to bind to sockets or open HttpRequests when running on a test
/// server.  This class is intentionally left with a minimal interface because
/// there's no utility in implementing and mocking the various http capabilities
/// that this package doesn't ever use.
abstract class HttpProvider {
  /// Sends a GET request to [url].
  Future<HttpResponse> get(String url);

  /// Sends a POST request to [url].
  Future<HttpResponse> post(String url, {String payload});

  /// Sends a DELETE request to [url].
  Future<HttpResponse> delete(String url);

  /// Binds an http server to [host] on [port].
  ///
  /// Returns a future that completes with the [SocketServer].
  Future<HttpServer> bindHttpServer(String host, int port);

  /// Binds a socket server to [host] on [port].
  ///
  /// This throws an [UnsupportedError] in the browser.
  Future<SocketServer> bindSocketServer(String host, int port);

  /// Binds a socket to [url].
  ///
  /// Returns a [Future] that completes with the [Socket].
  Future<Socket> connectSocket(String url);
}
