import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:meta/meta.dart';

/// Assembles and disassembles [String] messages into chunks small enough to
/// send in a [Datagram].
@immutable
class DataBuilder {
  @literal
  const DataBuilder();

  /// Reconstructs a [T] from its complete set of [datagrams].
  ///
  /// Assumes [parts] are in sorted order.
  String assembleParts(List<List<int>> parts) {
    final partsCopy = parts.map((p) => new List<int>.from(p)).toList();
    return partsCopy.map(utf8Decode).join();
  }

  /// Splits [data] into [DataPart]s small enough to send in a datagram.
  List<List<int>> splitIntoParts(String data) {
    final List<int> encoded = utf8Encode(data);
    final parts = <List<int>>[];

    for (int i = 0; i < encoded.length; i++) {
      parts.add([encoded[i]]);
    }

    return parts;
  }
}
