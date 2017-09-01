import 'package:distributed.ipc/src/protocol/typed_datagram.dart';
import 'package:distributed.ipc/src/protocol/typed_datagram_codec.dart';
import 'package:distributed.ipc/src/typedefs.dart';
import 'package:distributed.ipc/src/vm/vm_socket.dart';

/// Wraps a UDP socket as a
class DatagramSocket implements Sink<TypedDatagram> {
  static const _codec = const TypedDatagramCodec();
  final UdpSocket<List<int>> _socket;
  final _datagramConsumers = <Consumer<TypedDatagram>>[];

  DatagramSocket(this._socket) {
    _socket.forEach(_handleBytes);
  }

  @override
  void add(TypedDatagram dg) {
    _socket.add(_codec.encode(dg), dg.address, dg.port);
  }

  @override
  void close() {
    _socket.close();
  }

  void onDatagram(Consumer<TypedDatagram> consumer) {
    _datagramConsumers.add(consumer);
  }

  void _handleBytes(List<int> bytes) {
    if (bytes.isEmpty) return;
    final dg = _codec.decode(bytes);
    _datagramConsumers.forEach((handle) {
      handle(dg);
    });
  }
}
