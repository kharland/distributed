import 'dart:async';
import 'dart:io';

class Ports {
  /// Sentinel value for invalid port requests.
  static final error = -1;

  /// Returns the next available unused port.
  Future<int> getUnusedPort() =>
      ServerSocket.bind('localhost', 0).then((socket) {
        var port = socket.port;
        socket.close();
        return port;
      });
}
