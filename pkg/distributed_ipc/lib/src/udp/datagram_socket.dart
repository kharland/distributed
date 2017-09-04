import 'dart:async';

import 'package:distributed.ipc/src/internal/event_source.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:distributed.ipc/src/udp/datagram_codec.dart';
import 'package:distributed.ipc/src/udp/datagram_rewriter.dart';
import 'package:distributed.ipc/src/udp/raw_udp_socket.dart';

/// Wraps a UDP socket as a [Sink] and [EventSource] of [Datagram].
class DatagramSocket extends EventSource<Datagram> implements Sink<Datagram> {
  static const _codec = const Utf8DatagramCodec();
  static const _dgRewriter = const DatagramRewriter();

  final RawUdpSocket _socket;

  static Future<DatagramSocket> bind(String address, int port) async =>
      new DatagramSocket(await RawUdpSocket.bind(address, port));

  DatagramSocket(this._socket) {
    _socket.onData(_handleData);
  }

  String get address => _socket.address;

  int get port => _socket.port;

  @override
  void add(Datagram dg) {
    _socket.add(_codec.encode(dg), dg.address, dg.port);
  }

  @override
  void close() {
    _socket.close();
  }

  void _handleData(List<int> bytes, String address, int port) {
    if (bytes.isNotEmpty) {
      final originalDg = _codec.decode(bytes);
      emit(_dgRewriter.rewrite(originalDg, address: address, port: port));
    }
  }
}
