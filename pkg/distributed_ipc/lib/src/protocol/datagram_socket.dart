import 'package:distributed.ipc/src/protocol/typed_datagram.dart';
import 'package:distributed.ipc/src/protocol/typed_datagram_codec.dart';
import 'package:distributed.ipc/src/event_source.dart';
import 'package:distributed.ipc/src/vm/vm_socket.dart';

/// Wraps a UDP socket as a [Sink] and [EventSource] of [Datagram].
class DatagramSocket extends EventSource<Datagram> implements Sink<Datagram> {
  static const _codec = const DatagramCodec();
  final UdpSocket<List<int>> _socket;

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
      try {
        emit(_codec.decode(bytes));
      } catch (_) {
        // FIXME: Log error.
      }
    }
  }
}
