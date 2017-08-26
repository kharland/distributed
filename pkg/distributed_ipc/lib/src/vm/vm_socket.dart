import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/platform/vm.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/protocol/packet_codec.dart';
import 'package:distributed.ipc/src/socket.dart';
import 'package:distributed.ipc/src/utf8.dart';

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
abstract class UdpSocket<T> implements UdpSink<T>, Stream<T> {
  static const _codec = const PacketCodec();

  /// Creates a new [UdpSocket] from [config].
  static Future<UdpSocket> bind(UdpSocketConfig config) async {
    final rawSocket = null;
    final socket = convert<io.Datagram, Packet>(rawSocket, _codec);

    switch (config.transferMode) {
      case TransferType.lockstep:
        throw new UnimplementedError();
      case TransferType.fast:
        throw new UnimplementedError();
      default:
        throw new UnsupportedError('${config.transferMode}');
    }
  }

  /// Converts [socket] into a [Socket] of [U] using [codec].
  static UdpSocket<U> convert<T, U>(UdpSocket<T> socket, Codec<U, T> codec) {
    final stream = socket.map(codec.decode);
    final sink = new EncodedUdpSocketSink<T, U>(socket, codec.encoder);
    return new PseudoUdpSocket<U>(stream, sink);
  }
}

abstract class UdpSink<T> {
  /// Sends [data] to [address] and [port].
  void add(T data, String address, int port);

  /// Closes this socket.
  void close();
}

/// A [SocketSink] that converts a [T] data to send over a [SocketSink] of [S].
class EncodedUdpSocketSink<S, T> implements UdpSink<T> {
  final Converter<T, S> _converter;
  final UdpSink<S> _sink;

  EncodedUdpSocketSink(this._sink, this._converter);

  @override
  void add(T data, String address, int port) {
    _sink.add(_converter.convert(data), address, port);
  }

  @override
  void close() {
    _sink.close();
  }
}

class PseudoUdpSocket<T> extends StreamView<T> implements UdpSocket<T> {
  final UdpSink<T> _sink;

  PseudoUdpSocket(Stream<T> stream, this._sink) : super(stream);

  @override
  void add(T packet, String address, int port) {
    _sink.add(packet, address, port);
  }

  @override
  void close() {
    _sink.close();
  }
}

//class _UdpSocketImpl extends StreamView<String> implements UdpSocket<String> {
//  final PacketCourier _courier;
//
//  _UdpSocketImpl(this._courier) : super(_courier.data);
//
//  @override
//  void add(String data, String address, int port) {
//    _courier.add(data, address, port);
//  }
//
//  @override
//  void close() {
//    _courier.dispose();
//  }
//}
//
///// A [Socket] implementation that communicates using datagrams.
//@visibleForTesting
//class RawUdpSocket extends StreamView<List<int>>
//    implements UdpSocket<List<int>> {
//  final UdpAdapter _adapter;
//  final _output = new StreamController<io.Datagram>(sync: true);
//
//  /// Creates a [RawUdpSocket] connected to [address] and [port].
//  static Future<RawUdpSocket> bind(String address, int port) async {
//    final rawSock = await io.RawDatagramSocket.bind(address, port);
//    final udpSocket = new UdpAdapter(rawSock);
//    return new RawUdpSocket(udpSocket);
//  }
//
//  RawUdpSocket(this._adapter) : super(_adapter.datagrams);
//
//  /// The local address of this [RawUdpSocket].
//  String get localAddress => _adapter.localAddress;
//
//  /// The local port of this [RawUdpSocket].
//  int get localPort => _adapter.localPort;
//
//  Stream<io.Datagram> get stream => _output.stream;
//
//  @override
//  void add(List<int> data, String address, int port) {
//    _adapter.add(data, address, port);
//  }
//
//  @override
//  void close() {
//    _adapter.close();
//  }
//}

/// Wraps an [io.RawDatagramSocket].
///
/// Also provides a broadcast stream of the Datagrams received on the
/// socket via [datagrams].
class UdpAdapter {
  final io.RawDatagramSocket _socket;
  final _output = new StreamController<io.Datagram>(sync: true);

  UdpAdapter(this._socket) {
    _socket
      ..writeEventsEnabled = false
      ..map(_handleEvent);
  }

  /// The stream of datagrams received by this adapter.
  Stream<io.Datagram> get datagrams => _output.stream;

  /// The local address of this socket.
  String get localAddress => _socket.address.address;

  /// The local port of this socket.
  int get localPort => _socket.port;

  /// Sends [event] to [address] and [port].
  void add(List<int> event, String address, int port) {
    _socket.send(event, new io.InternetAddress(address), port);
  }

  /// Disables this adapter.
  void close() {
    _socket.close();
  }

  void _handleEvent(io.RawSocketEvent event) {
    switch (event) {
      case io.RawSocketEvent.CLOSED:
        _socket.close();
        break;
      case io.RawSocketEvent.READ:
        final datagram = _socket.receive();
        _output.add(datagram);
        break;
      default:
        throw new UnsupportedError('$event');
    }
    // RawSocketEvent.READ_CLOSED will never be received; The remote peer cannot
    // close the socket.
  }
}
