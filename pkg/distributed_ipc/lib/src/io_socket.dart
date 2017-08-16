import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:distributed.ipc/src/socket.dart';

/// A [Socket] implementation backed by an [io.Socket].
class IoSocket extends GenericSocket<String> {
  static Future<IoSocket> connect(io.InternetAddress address, int port) async =>
      new IoSocket(await io.Socket.connect(address, port));

  IoSocket(io.Socket socket)
      : super(
            socket.map<String>(const Utf8Decoder().convert),
            new EncodedSocketSink<List<int>, String>(
                socket, const Utf8Encoder()));
}

/// A [Socket] implementation that uses the UDP protocol.
class IoDatagramSocket extends GenericSocket<List<int>> {
  static Future<IoDatagramSocket> connect(
      io.InternetAddress address, int port) async {
    final udpSocket =
        await io.RawDatagramSocket.bind(io.InternetAddress.ANY_IP_V4, 0);
    return new IoDatagramSocket(
      new _UdpSocketReader(udpSocket),
      new _UdpSocketWriter(udpSocket, address, port),
    );
  }

  IoDatagramSocket(_UdpSocketReader reader, _UdpSocketWriter writer)
      : super(reader.stream, writer);
}

/// An [EventSink] that writes data to a [RawDatagramSocket].
///
/// The writer can only write to a single address and port.
class _UdpSocketWriter extends EventSink<List<int>> {
  final io.RawDatagramSocket _socket;
  final io.InternetAddress _address;
  final int _port;

  _UdpSocketWriter(this._socket, this._address, this._port);

  @override
  void add(List<int> event) {
    _socket.send(event, _address, _port);
  }

  @override
  void addError(Object errorEvent, [StackTrace stackTrace]) {
    throw new UnsupportedError('addError');
  }

  @override
  void close() {
    _socket.close();
  }
}

/// Reads from a [RawDatagramSocket].
///
/// Translated data are emitted as [String]s on [stream].
class _UdpSocketReader {
  final io.RawDatagramSocket _socket;
  final _streamController = new StreamController<List<int>>();

  _UdpSocketReader(this._socket) {
    _socket
      ..writeEventsEnabled = false
      ..forEach(_handleEvent);
  }

  Stream<List<int>> get stream => _streamController.stream;

  void _handleEvent(io.RawSocketEvent event) {
    switch (event) {
      case io.RawSocketEvent.CLOSED:
        _socket.close();
        break;
      case io.RawSocketEvent.READ:
        final datagram = _socket.receive();
        _streamController.add(datagram.data);
        break;
      default:
        throw new UnsupportedError('$event');
    }
    // RawSocketEvent.READ_CLOSED will never be received: a remote peer cannot
    // close the socket.
  }
}
