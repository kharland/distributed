import 'dart:async';

import 'package:distributed.ipc/platform/vm.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/protocol/packet_codec.dart';
import 'package:distributed.ipc/src/vm/vm_socket.dart';

/// An I/O channel for transferring [Packets] between processes.
abstract class PacketChannel {
  static const DefaultCodec = const Utf8PacketCodec();

  /// Creates a [PacketChannel] that uses the specified [transferType].
  factory PacketChannel.fromTransferType(
    TransferType transferType,
    PacketChannelConfig config,
    UdpSink<List<int>> sink,
  ) {
    switch (transferType) {
      case TransferType.FAST:
        throw new UnimplementedError();
      default:
        throw new ArgumentError(transferType);
    }
  }

  /// The stream of packets received on this channel.
  ///
  /// A contiguous sequence of packets begins with the first packet in the
  /// sequence, and ends with an [ENDPacket].
  Stream<Packet> get packets;

  /// Sends [packets] on this channel.
  void send(Iterable<Packet> packets);

  /// Recieves [packet] on this channel.
  void receive(Packet packet);

  /// Closes this channel.
  void close();
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
  final UdpSink<List<int>> _sink;
  final String _address;
  final PacketCodec _codec;
  final int _port;
  final _packetsController = new StreamController<Packet>(sync: true);

  FastPacketChannel.fromConfig(
      PacketChannelConfig config, UdpSink<List<int>> sink)
      : this(config.address, config.port, sink, config.codec);

  FastPacketChannel(
    this._address,
    this._port,
    this._sink, [
    this._codec = PacketChannel.DefaultCodec,
  ]);

  @override
  Stream<Packet> get packets => _packetsController.stream;

  @override
  void send(Iterable<Packet> packets) {
    packets.forEach((packet) {
      _sink.add(_codec.encode(packet), _address, _port);
    });
  }

  @override
  void close() {
    _packetsController.close();
  }

  @override
  void receive(Packet packet) {
    _packetsController
      ..add(packet)
      ..add(new Packet(PacketType.END, packet.address, packet.port));
  }

  // bool _isFromPartner(io.Datagram dg) =>
  //     dg.address.address == _address && dg.port == _port;

}
