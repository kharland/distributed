import 'dart:async';

import 'package:distributed.ipc/src/protocol/typed_datagram.dart';
import 'package:distributed.ipc/src/protocol/typed_datagram_codec.dart';
import 'package:distributed.ipc/src/vm/vm_socket.dart';
import 'package:meta/meta.dart';

typedef TypedDatagramHandler = void Function(TypedDatagram);

class TypedDatagramAdapter {
  static const _codec = const TypedDatagramCodec();

  final UdpSink<List<int>> _sink;
  final Stream<List<int>> _byteStream;
  final TypedDatagramHandler _onGreet;

  /// Handlers for non-greet datagrams.
  final List<TypedDatagramHandler> _onDatagramHandlers;

  TypedDatagramAdapter(
    this._sink,
    this._byteStream, {
    @required TypedDatagramHandler onGreet,
    @required TypedDatagramHandler onDatagram,
  })
      : _onGreet = onGreet,
        _onDatagramHandlers = [onDatagram] {
    _byteStream.forEach(_handleBytes);
  }

  void add(TypedDatagram dg) {
    _sink.add(_codec.encode(dg), dg.address, dg.port);
    // [dg.type]..addAll(dg.data), dg.address, dg.port);
  }

  void addDatagramHandler(TypedDatagramHandler handler) {
    _onDatagramHandlers.add(handler);
  }

  void _handleBytes(List<int> bytes) {
    if (bytes.isEmpty) return;
    final dg = _codec.decode(bytes);

    switch (dg.type) {
      case DatagramType.GREET:
        _onGreet(dg);
        break;
      case DatagramType.DEFAULT:
        _onDatagramHandlers.forEach((handler) => handler(dg));
        break;
      default:
        return;
    }
  }
}
