import 'dart:async';
import 'dart:io' as io;

import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/protocol/packet_codec.dart';
import 'package:distributed.ipc/src/vm/vm_socket.dart';

/// An I/O channel for transferring [Packets] between processes.
abstract class PacketChannel {
  static const DefaultCodec = const Utf8PacketCodec();

  /// Sends [packets] on this channel.
  void send(Iterable<Packet> packets);

  /// The stream of packets received on this channel.
  ///
  /// A contiguous sequence of packets begins with the first packet in the
  /// sequence, and ends with an [ENDPacket].
  Stream<Packet> get packets;
}

/// A [PacketChannel] that does not wait for acknowledgement of packets.
///
/// All packets are immediately sent on the channel and no attempt is made to
/// verify whether the remote received each packet.  This channel is lossy, and
/// best used for applications that prioritize speed over, integrity such as
/// game-servers or stream applications.
///
/// The remote is not expected to send [ENDPacket]s.  They are implicitly
/// received after each [Packet].
class FastPacketChannel implements PacketChannel {
  final UdpAdapter _adapter;
  final String _address;
  final PacketCodec _codec;
  final int _port;

  final _packetsController = new StreamController<Packet>(sync: true);

  FastPacketChannel(
    this._adapter,
    this._address,
    this._port, [
    this._codec = PacketChannel.DefaultCodec,
  ]) {
    _adapter.datagrams
        .where(_isFromPartner)
        .map(_createDataPacket)
        .forEach(_emitPacket);
  }

  @override
  Stream<Packet> get packets => _packetsController.stream;

  @override
  void send(Iterable<Packet> packets) {
    packets.forEach((packet) {
      _adapter.add(_codec.encode(packet), _address, _port);
    });
  }

  void _emitPacket(Packet packet) {
    _packetsController
      ..add(packet)
      ..add(new Packet(PacketTypes.END, packet.address, packet.port));
  }

  bool _isFromPartner(io.Datagram dg) =>
      dg.address.address == _address && dg.port == _port;

  Packet _createDataPacket(io.Datagram dg) =>
      new DataPacket(dg.address.address, dg.port, dg.data, 1);
}

/// A [PacketChannel] that transfers packets until all have been exchanged.
///
/// Packets are emitted in the order they were intended to be sent. This means
/// that a dropped packet must be be re-requested and received before this
/// channel will emit its predecessor.  If packets must be re-sent more than
/// [numRetries] times, all packets in the sequence are dropped and sequence is
/// not emitted.
class BatchPacketChannel implements PacketChannel {
  @override
  Stream<Packet> get packets => throw new UnimplementedError();

  @override
  void send(Iterable<Packet> packets) {
    throw new UnimplementedError();
  }
}
