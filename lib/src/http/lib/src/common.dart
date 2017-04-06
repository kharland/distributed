import 'dart:async';

import 'package:distributed.http/src/configuration.dart';

/// Sends a GET request.
Future<HttpResponse> get(String url) => http.get(url);

/// Sends a POST request.
Future<HttpResponse> post(String url, {String payload}) =>
    http.post(url, payload: payload);

/// Sends a DELETE request.
Future<HttpResponse> delete(String url) => http.delete(url);

/// A server-side HTTP request.
abstract class HttpRequest implements Stream<String> {
  /// The method, such as 'GET' or 'POST', for the request.
  String get method;

  /// The URI for the request.
  Uri get uri;

  /// An object for replying to the client.
  HttpResponder get response;
}

/// An HTTP response object, for replying to an HttpRequest.
///
/// This is akin to `HttpRequest.response` from dart:io.
abstract class HttpResponder {
  void add(String data);

  void close();
}

/// The response to an [HttpRequest].
abstract class HttpResponse implements Stream<String> {}

/// A server that listens for HTTP requests.
abstract class HttpServer implements Stream<HttpRequest> {
  /// Binds an HttpServer to [address] on [port].
  ///
  /// Returns a future that completes with the server.
  static Future<HttpServer> bind(String address, int port) =>
      http.bindHttpServer(address, port);

  /// The address of this server.
  String get address;

  /// The port the server is bound to.
  int get port;

  /// Closes this server.
  void close();
}

/// A two-way communication channel.
abstract class Socket implements Stream<String>, Sink<String> {
  /// Initiates a [Socket] connection over [url].
  static Future<Socket> connect(String url) => http.connectSocket(url);

  /// The local port this socket is using.
  int get port;

  /// The local host of this socket.
  String get localHost;

  /// The host at the remote end of this socket.
  String get remoteHost;
}
