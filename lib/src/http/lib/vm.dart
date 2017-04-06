import 'dart:async';

import 'package:distributed.http/src/configuration.dart';
import 'package:distributed.http/src/common.dart';
export 'package:distributed.http/src/common.dart';

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
