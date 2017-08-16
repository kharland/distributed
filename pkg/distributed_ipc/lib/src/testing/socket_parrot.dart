import 'dart:async';
import 'dart:io';

/// Echoes all data sent over a [RawDatagramSocket] back to the sender.
class RawSocketParrot {
  final RawDatagramSocket _socket;

  /// Creates a [RawSocketParrot] listening at [address] and [port].
  static Future<RawSocketParrot> bind(
          InternetAddress address, int port) async =>
      new RawSocketParrot(await RawDatagramSocket.bind(address, port));

  RawSocketParrot(this._socket) {
    _socket
      ..writeEventsEnabled = false
      ..forEach((RawSocketEvent event) {
        switch (event) {
          case RawSocketEvent.CLOSED:
            _socket.close();
            break;
          case RawSocketEvent.READ:
            final datagram = _socket.receive();
            _socket.send(datagram.data, datagram.address, datagram.port);
            break;
          default:
            throw new UnsupportedError('$event');
        }
      });
  }

  void close() {
    _socket.close();
  }
}

/// Echoes all data sent over a [Socket] back to the sender.
class SocketParrot {
  final ServerSocket _serverSocket;
  final _sockets = <Socket>[];

  /// Creates a [RawSocketParrot] listening at [address] and [port].
  static Future<SocketParrot> bind(InternetAddress address, int port) async =>
      new SocketParrot(await ServerSocket.bind(address, port));

  SocketParrot(this._serverSocket) {
    _serverSocket.listen((Socket socket) {
      _sockets.add(socket);
      socket.forEach(socket.add);
    });
  }

  void close() {
    _serverSocket.close();
    _sockets.forEach((s) => s.close());
  }
}
