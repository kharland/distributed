import 'package:distributed.ipc/src/internal/event_source.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:distributed.ipc/src/udp/datagram_codec.dart';
import 'package:distributed.ipc/src/udp/raw_udp_socket.dart';

/// Wraps a UDP socket as a [Sink] and [EventSource] of [Datagram].
class DatagramSocket extends EventSource<Datagram> implements Sink<Datagram> {
  static const _codec = const Utf8DatagramCodec();
  final RawUdpSocket _socket;

  DatagramSocket(this._socket) {
    _socket.onEvent(_handleBytes);
  }

  String get address => _socket.address;

  int get port => _socket.port;

  @override
  void add(Datagram dg) {
    // FIXME: Higher levels in the netstack shouldn't be creating the datagram.
    // They should be passing its contents down to this level where it gets
    // encoded with the correct address and port so that we don't have to
    // re-write the datagram like this.
    final datagram = new Datagram(dg.type, address, port, dg.data);
    _socket.add(_codec.encode(datagram), dg.address, dg.port);
  }

  @override
  void close() {
    _socket.close();
  }

  void _handleBytes(List<int> bytes) {
    if (bytes.isNotEmpty) {
      emit(_codec.decode(bytes));
    }
  }
}
