import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';

/// Creates a [DataDatagram] of [data] whose relative position in a sequence of
/// [DataDatagram]s is [position].
typedef DataDatagramFactory = DataDatagram Function(
    List<int> data, int position);

/// Assembles and disassembles [String] messages into a [List] of [Datagram].
class DataBuilder {
  final DataDatagramFactory _createDatagram;

  DataBuilder(this._createDatagram);

  /// Reconstructs a [T] from its complete set of [datagrams].
  String assembleDatagrams(List<DataDatagram> pieces) {
    assert(pieces.every((p) => p.type == DatagramType.DATA));

    pieces.sort((a, b) => a.position.compareTo(b.position));
    return utf8Decode(pieces.map((p) => p.payload).expand((bytes) => bytes));
  }

  /// Splits [data] into [DataDatagram]s small enough to send in a datagram.
  List<DataDatagram> createDatagrams(String data) {
    final List<int> encoded = utf8Encode(data);
    final datagrams = <Datagram>[];

    for (int i = 0; i < encoded.length; i++) {
      datagrams.add(_createDatagram([encoded[i]], i));
    }

    return datagrams;
  }
}
