import 'dart:async';
import 'dart:io' as io;

import 'package:distributed.ipc/src/internal/consumer.dart';
import 'package:distributed.ipc/src/internal/event_source.dart';

/// A socket that uses the UDP protocol.
///
/// Messages sent on the socket are split into chunks of datagrams.  The size of
/// size of a datagram can be specified in the given [UdpSocketConfig].  The
/// splitting is done to support sending message that are usually considered too
/// large to fit within a single datagram.
///
/// If a message is added to the socket while a previous message is still
/// in-flight, the new message is added to a queue and sent after all previously
/// enqueued messages.
abstract class RawUdpSocket implements UdpSink {
  /// Creates a new [RawUdpSocket] from [config].
  static Future<RawUdpSocket> bind(String address, int port) async {
    final rawSocket = await io.RawDatagramSocket.bind(address, port);
    final adapter = new _UdpAdapter(rawSocket);
    return new _AdapterUdpSocket(adapter);
  }

  /// The socket's address.
  String get address;

  /// This socket's port.
  int get port;

  /// Closes this socket.
  void close();

  /// Subscribes [consumer] to data events on this socket.
  ///
  /// The consumer receives the [List] of [int] data that was sent, the,
  /// [String] address of the sender and the [int] port of the sender.
  void onData(Consumer3<List<int>, String, int> consumer);
}

abstract class UdpSink {
  /// Sends [data] to [address] and [port].
  void add(List<int> data, String address, int port);
}

/// A [RawUdpSocket] that delegates to a [_UdpAdapter].
class _AdapterUdpSocket implements RawUdpSocket {
  final _UdpAdapter _adapter;
  final _consumers = <Consumer3<List<int>, String, int>>[];

  _AdapterUdpSocket(this._adapter) {
    _adapter.onEvent((io.Datagram dg) {
      _emit(dg.data, dg.address.address, dg.port);
    });
  }

  @override
  String get address => _adapter.address;

  @override
  int get port => _adapter.port;

  @override
  void add(List<int> data, String address, int port) {
    _adapter.add(data, address, port);
  }

  @override
  void close() {
    _adapter.close();
  }

  @override
  void onData(Consumer3<List<int>, String, int> consumer) {
    _consumers.add(consumer);
  }

  void _emit(List<int> data, String senderAddress, int senderPort) {
    _consumers.forEach((consume) {
      consume(data, senderAddress, senderPort);
    });
  }
}

/// Wraps an [io.RawDatagramSocket].
///
/// Also provides a broadcast stream of the Datagrams received on the
/// socket via [datagrams].
class _UdpAdapter extends EventSource<io.Datagram> {
  final io.RawDatagramSocket _socket;

  _UdpAdapter(this._socket) {
    _socket
      ..writeEventsEnabled = false
      ..forEach(_handleEvent);
  }

  /// The local address of this socket.
  String get address => _socket.address.address;

  /// The local port of this socket.
  int get port => _socket.port;

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
