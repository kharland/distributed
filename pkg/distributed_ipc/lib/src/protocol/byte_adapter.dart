import 'dart:async';
import 'dart:io' as io;

import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/vm/vm_socket.dart';

abstract class ByteAdapter {
  static const _GREET_SIG = 0x12345678;
  static const _DATA_SIG = 0x23456781;
  static const _DEFAULT_SIG = 0x34567812;

  final _signatureToStreamController = <int, StreamController<List<int>>>{
    _GREET_SIG: new StreamController<List<int>>(sync: true),
    _DATA_SIG: new StreamController<List<int>>(sync: true),
    _DEFAULT_SIG: new StreamController<List<int>>(sync: true),
  };

  static final _packetTypeToSignature = <int, int>{
    PacketTypes.DATA.value: _DATA_SIG,
    PacketTypes.GREET.value: _GREET_SIG,
  };

  final UdpAdapter _adapter;

  ByteAdapter(this._adapter) {
    _adapter.datagrams.forEach(_handleDatagram);
  }

  Stream<List<int>> get dataBytes =>
      _signatureToStreamController[_DATA_SIG].stream;

  Stream<List<int>> get greetBytes =>
      _signatureToStreamController[_GREET_SIG].stream;

  Stream<List<int>> get otherBytes =>
      _signatureToStreamController[_DEFAULT_SIG].stream;

  void addBytes(
    List<int> data,
    String address,
    int port,
    PacketTypes packetType,
  ) {
    final signature = _packetTypeToSignature[packetType.value] ?? _DEFAULT_SIG;
    final signedData = [signature]..addAll(data);
    _adapter.add(signedData, address, port);
  }

  void _handleDatagram(io.Datagram dg) {
    if (dg.data.isEmpty) return;

    final signature = dg.data.first;
    if (_signatureToStreamController.containsKey(signature)) {
      _signatureToStreamController[signature].add(dg.data.skip(1).toList());
    }
  }
}
