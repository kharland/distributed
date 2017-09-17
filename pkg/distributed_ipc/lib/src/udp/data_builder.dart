import 'dart:convert';

import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:meta/meta.dart';

/// Assembles and disassembles [String] messages into chunks small enough to
/// send in a [Datagram].
@immutable
class DataBuilder {
  final Codec _codec;

  @literal
  const DataBuilder([this._codec = const Utf8Codec()]);

  /// Reconstructs a [String] from its complete set of [parts].
  ///
  /// Assumes [parts] are in sorted order.
  String assembleParts(List<List<int>> parts) {
    final partsCopy = parts.map((p) => new List<int>.from(p)).toList();
    return partsCopy.map(_codec.decode).join();
  }

  /// Splits [data] into [DataPart]s small enough to send in a datagram.
  List<List<int>> splitIntoParts(String data) {
    final encoded = _codec.encode(data);
    final parts = <List<int>>[];

    for (int i = 0; i < encoded.length; i++) {
      parts.add([encoded[i]]);
    }

    return parts;
  }
}
