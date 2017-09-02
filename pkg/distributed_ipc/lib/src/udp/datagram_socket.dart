import 'package:distributed.ipc/src/internal/event_source.dart';
import 'package:distributed.ipc/src/internal/pipe.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:distributed.ipc/src/udp/datagram_codec.dart';
import 'package:distributed.ipc/src/udp/raw_udp_socket.dart';

/// Wraps a UDP socket as a [Sink] and [EventSource] of [Datagram].
class DatagramSocket extends EventSource<Datagram> implements Pipe<Datagram> {
  static const _codec = const Utf8DatagramCodec();
  final RawUdpSocket _socket;

  DatagramSocket(this._socket) {
    _socket.onEvent(_handleBytes);
  }

  @override
  void add(Datagram dg) {
    _socket.add(_codec.encode(dg), dg.address, dg.port);
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
