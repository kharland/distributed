import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';

/// Creates a [DataDatagram] of [data] whose relative position in a sequence of
/// [DataDatagram]s is [position].
typedef DataDatagramFactory = DataDatagram Function(
    List<int> data, int position);

/// Assembles and disassembles mess ages so they may be sent over a UDP socket.
abstract class DataBuilder<T> {
  /// Reconstructs a [T] from its complete set of [datagrams].
  T construct(List<DataDatagram> datagrams);

  /// Splits [data] into [DataDatagram]s small enough to send in a datagram.
  List<DataDatagram> deconstruct(T data);
}

/// A [DataBuilder] that assembles and disassembles strings.
class StringDataBuilder implements DataBuilder<String> {
  final DataDatagramFactory _createDataDatagram;

  StringDataBuilder(this._createDataDatagram);

  @override
  String construct(List<DataDatagram> pieces) {
    assert(pieces.every((p) => p.type == DatagramType.DATA));

    pieces.sort((a, b) => a.position.compareTo(b.position));
    return utf8Decode(pieces.map((p) => p.payload).expand((bytes) => bytes));
  }

  @override
  List<DataDatagram> deconstruct(String data) {
    final List<int> encoded = utf8Encode(data);
    final datagrams = <Datagram>[];

    for (int i = 0; i < encoded.length; i++) {
      datagrams.add(_createDataDatagram([encoded[i]], i));
    }

    return datagrams;
  }
}
