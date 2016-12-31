import 'dart:async';
import 'dart:io';
import 'package:fixnum/fixnum.dart';

class Ports {
  /// Sentinel value for invalid port requests.
  static final invalidPort = new Int64(-1);

  /// Returns the next available unused port.
  Future<Int64> getUnusedPort() =>
      ServerSocket.bind('localhost', 0).then((socket) {
        var port = socket.port;
        socket.close();
        return new Int64(port);
      });
}
