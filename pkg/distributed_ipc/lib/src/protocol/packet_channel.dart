import 'dart:async';

import 'package:distributed.ipc/platform/vm.dart';
import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/protocol/packet_codec.dart';

typedef PacketHandler = void Function(Packet);

/// An I/O channel for transferring [Packets] between processes.
abstract class PacketChannel {
  static const DefaultCodec = const Utf8PacketCodec();

  /// Creates a [PacketChannel] that uses the specified [transferType].
  factory PacketChannel.fromConfig(PacketChannelConfig config) {
    switch (config.transferType) {
      case TransferType.FAST:
        throw new UnimplementedError();
      default:
        throw new ArgumentError(config.transferType);
    }
  }

  /// The address of this channel's remote peer.
  String get remoteAddress;

  /// The port of this channel's remote peer.
  int get remotePort;

  /// Sends [packets] on this channel.
  void send(Iterable<Packet> packets);

  /// Receives an encoded packet on this channel.
  void receive(Iterable<int> encodedPacket);

  /// Adds [handler] as a handler to call when a packet is recieved.
  void addPacketHandler(PacketHandler handler);
}

/// Specifies the settings necessary to create a [PacketChannel].
class PacketChannelConfig {
  final TransferType transferType;
  final EncodingType encodingType;
  final String address;
  final int port;

  PacketChannelConfig(
    this.address,
    this.port, {
    this.transferType: TransferType.FAST,
    this.encodingType: EncodingType.UTF8,
  });
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
  /// Handlers for incoming packets.
  final _packetHandlers = <PacketHandler>[];

  /// Sink for outgoing data.
  final Sink<List<int>> _sink;

  @override
  final String remoteAddress;

  @override
  final int remotePort;

  final PacketCodec _codec;

  FastPacketChannel.fromConfig(PacketChannelConfig config, Sink<List<int>> sink)
      : this(
          config.address,
          config.port,
          sink,
          new PacketCodec.fromEncoding(config.encodingType),
        );

  FastPacketChannel(
    this.remoteAddress,
    this.remotePort,
    this._sink, [
    this._codec = PacketChannel.DefaultCodec,
  ]);

  @override
  void send(Iterable<Packet> packets) {
    packets.map(_codec.encode).forEach(_sink.add);
  }

  @override
  void receive(Iterable<int> encodedPacket) {
    final packet = _codec.decode(encodedPacket);
    _packetHandlers.forEach((handler) {
      handler(packet);
      // Receive implicit END packet.
      handler(Packet.end(packet.address, packet.port));
    });
  }

  @override
  void addPacketHandler(PacketHandler handler) {
    _packetHandlers.add(handler);
  }
}
