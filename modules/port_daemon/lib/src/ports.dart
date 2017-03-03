import 'dart:async';
import 'dart:io';

abstract class Ports {
  /// Sentinel value for invalid port requests.
  static const error = -1;

  static const defaultDaemonPort = 4369;

  /// Returns the next available unused port.
  static Future<int> getUnusedPort() =>
      ServerSocket.bind('localhost', 0).then((socket) {
        var port = socket.port;
        socket.close();
        return port;
      });
}
