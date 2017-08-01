import 'dart:async';

import 'package:distributed.http/src/configuration.dart';

abstract class ServerHttpRequest extends Stream<String> {
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
abstract class HttpResponder implements Sink<String> {
  @override
  void add(String data);

  @override
  void close();
}

/// A server that listens for HTTP requests.
abstract class HttpServer implements Stream<ServerHttpRequest> {
  /// Binds an HttpServer to [address] on [port].
  ///
  /// Returns a future that completes with the server.
  static Future<HttpServer> bind(String address, int port) =>
      http.bindHttpServer(address, port);

  /// The address of this server.
  String get address;

  /// The port the server is bound to.
  int get port;

  String get url => 'http://$address:$port';

  /// Closes this server.
  void close();
}

/// A two-way communication channel.
abstract class Socket implements Stream<String>, Sink<String> {
  /// Initiates a [Socket] connection over [url].
  static Future<Socket> connect(String url) => http.connectSocket(url);

  /// The local port this socket.dart is using.
  int get port;

  /// The local host of this socket.dart.
  String get localHost;

  /// The host at the remote end of this socket.dart.
  String get remoteHost;
}

/// A server that listens for Socket requests.
abstract class SocketServer implements Stream<Socket> {
  /// Binds an HttpServer to [address] on [port].
  ///
  /// Returns a future that completes with the server.
  static Future<SocketServer> bind(String address, int port) =>
      http.bindSocketServer(address, port);

  /// The address of this server.
  String get address;

  /// The port the server is bound to.
  int get port;

  /// Closes this server.
  void close();
}
