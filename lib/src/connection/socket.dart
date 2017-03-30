import 'dart:async';

import 'package:distributed/src/connection/http_socket.dart';

/// A bidirectional communication channel.
abstract class Socket implements Stream<String>, Sink<String> {
  /// Initiates a [Socket] connection over [url].
  static Future<Socket> connect(String url) => HttpSocket.connect(url);

  /// The address of the remote endpoint of this socket.
  String get remoteHost;
}
