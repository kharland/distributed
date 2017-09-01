import 'dart:async';
import 'dart:io' as io;

import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/socket.dart';
import 'package:distributed.ipc/src/typedefs.dart';

/// A [Socket] implementation backed by an [io.Socket].
class VmSocket extends PseudoSocket<String> {
  static Future<VmSocket> connect(io.InternetAddress address, int port) async =>
      new VmSocket(await io.Socket.connect(address, port));

  VmSocket(io.Socket socket)
      : super(socket.map<String>(utf8Decode),
            new EncodedSocketSink<List<int>, String>(socket, utf8Encoder));
}

/// A [Socket] implementation that communicates using datagrams.
///
/// Messages sent on the socket are split into chunks called [Packet]s.  The
/// size of the packet can be specified in the given [UdpSocketConfig].  This
/// splitting is done to support sending message that are usually considered too
/// large to fit within a datagram.
///
/// If a message is added to the socket while a previous message is still
/// in-flight, the new message is added to a queue and sent after all previously
/// enqueued messages.
abstract class UdpSocket<T> implements UdpSink<T>, EventBus<T> {
  /// Creates a new [UdpSocket] from [config].
  static Future<UdpSocket<List<int>>> bind(String address, int port) async {
    final rawSocket = await io.RawDatagramSocket.bind(address, port);
    final adapter = new _UdpAdapter(rawSocket);
    return new _AdapterUdpSocket(adapter);
  }
}

/// A sink interface for [UdpSocket]-like objects.
abstract class UdpSink<T> {
  /// Sends [data] to [address] and [port].
  void add(T data, String address, int port);

  /// Closes this socket.
  void close();
}

/// A [UdpSocket] created by stitching together a [Stream] and [UdpSocketSink].
class _AdapterUdpSocket extends EventBus<List<int>>
    implements UdpSocket<List<int>> {
  final _UdpAdapter _adapter;

  _AdapterUdpSocket(this._adapter) {
    _adapter.onEvent((io.Datagram dg) {
      emit(dg.data);
    });
  }

  @override
  void add(List<int> data, String address, int port) {
    _adapter.add(data, address, port);
  }

  @override
  void close() {
    _adapter.close();
  }
}

/// Wraps an [io.RawDatagramSocket].
///
/// Also provides a broadcast stream of the Datagrams received on the
/// socket via [datagrams].
class _UdpAdapter extends EventBus<io.Datagram> {
  final io.RawDatagramSocket _socket;

  _UdpAdapter(this._socket) {
    _socket
      ..writeEventsEnabled = false
      ..map(_handleEvent);
  }

  /// The local address of this socket.
  String get localAddress => _socket.address.address;

  /// The local port of this socket.
  int get localPort => _socket.port;

  /// Sends [event] to [address] and [port].
  void add(List<int> event, String address, int port) {
    _socket.send(event, new io.InternetAddress(address), port);
  }

  void close() {
    _socket.close();
  }

  void _handleEvent(io.RawSocketEvent event) {
    switch (event) {
      case io.RawSocketEvent.CLOSED:
        _socket.close();
        break;
      case io.RawSocketEvent.READ:
        emit(_socket.receive());
        break;
      default:
        throw new UnsupportedError('$event');
    }
    // RawSocketEvent.READ_CLOSED will never be received; The remote peer cannot
    // close the socket.
  }
}
