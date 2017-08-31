import 'dart:async';
import 'dart:io' as io;

import 'package:distributed.ipc/platform/vm.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/protocol/packet_codec.dart';
import 'package:distributed.ipc/src/vm/vm_socket.dart';

/// An I/O channel for transferring [Packets] between processes.
abstract class PacketChannel {
  static const DefaultCodec = const Utf8PacketCodec();

  factory PacketChannel.fromTransferType(
    TransferType transferType,
    PacketChannelConfig config,
  ) {
    switch (transferType) {
      case TransferType.FAST:
        throw new UnimplementedError();
      default:
        throw new ArgumentError(transferType);
    }
  }

  /// Sends [packets] on this channel.
  void send(Iterable<Packet> packets);

  /// The stream of packets received on this channel.
  ///
  /// A contiguous sequence of packets begins with the first packet in the
  /// sequence, and ends with an [ENDPacket].
  Stream<Packet> get packets;
}

/// Specifies the settings necessary to create a [PacketChannel].
class PacketChannelConfig {
  final PacketCodec codec;
  final String address;
  final int port;

  PacketChannelConfig(this.codec, this.address, this.port);
}

/// A [PacketChannel] that does not wait for acknowledgement of packets.
///
/// All packets are immediately sent on the channel and no attempt is made to
/// verify whether the remote received each packet.  This channel is lossy and
/// best used for applications that prioritize speed over reliability, such as
/// game-servers or streaming applications.
///
/// The remote is not expected to send end packets.  They are assumed after each
/// [Packet].
class FastPacketChannel implements PacketChannel {
  final Stream<List<int>> _byteStream;
  final _WriteData _write;
  final String _address;
  final PacketCodec _codec;
  final int _port;
  final _packetsController = new StreamController<Packet>(sync: true);

  FastPacketChannel.fromConfig(
      PacketChannelConfig config, Stream<List<int>> packets, _WriteData write)
      : this(config.address, config.port, packets, write, config.codec);

  FastPacketChannel(
    this._address,
    this._port,
    this._byteStream,
    this._write, [
    this._codec = PacketChannel.DefaultCodec,
  ]) {
    _byteStream.map(_codec.decode).forEach(_receivePacket);
  }

  @override
  Stream<Packet> get packets => _packetsController.stream;

  @override
  void send(Iterable<Packet> packets) {
    packets.forEach((packet) {
      _write(_codec.encode(packet), _address, _port);
    });
  }

  void _receivePacket(Packet packet) {
    _packetsController
      ..add(packet)
      ..add(new Packet(PacketTypes.END, packet.address, packet.port));
  }

  // bool _isFromPartner(io.Datagram dg) =>
  //     dg.address.address == _address && dg.port == _port;

}

typedef void _WriteData(List<int> data, String address, int port);
