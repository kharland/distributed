import 'package:distributed.ipc/platform/vm.dart';
import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/event_source.dart';
import 'package:distributed.ipc/src/pipe.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';

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

/// An I/O channel for transferring [Packets] between processes.
///
/// A [PacketChannel] consumes [Iterable]s of [Packet]s from the local client
/// and sends them over the network.  It consumes encoded [Packet] data from the
/// network and broadcasts the decoded [Packet]s locally.
abstract class PacketChannel implements EventSource<Packet> {
  /// Creates a [PacketChannel].
  ///
  /// [config] is the [PacketChannelConfig] to create the channel from.
  /// [writeData] is a callback for writing packet data to the remote peer.
  factory PacketChannel.fromConfig(
    PacketChannelConfig config,
    Pipe<Packet> pipe,
  ) {
    switch (config.transferType) {
      case TransferType.FAST:
        return new FastPacketChannel(config, pipe);
      default:
        throw new ArgumentError(config.transferType);
    }
  }

  /// The address of this channel's remote peer.
  String get remoteAddress;

  /// The port of this channel's remote peer.
  int get remotePort;

  /// Sends [packet] on this channel.
  void add(Packet packet);

  /// Sends [packets] on this channel.
  void addAll(Iterable<Packet> packets);

  /// Receives a [packet] sent from [remoteAddress] and [remotePort].
  void receive(Packet packet);
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
class FastPacketChannel extends EventSource<Packet> implements PacketChannel {
  final Pipe<Packet> _pipe;

  @override
  final String remoteAddress;

  @override
  final int remotePort;

  FastPacketChannel(PacketChannelConfig config, Pipe<Packet> pipe)
      : this._(config.address, config.port, pipe);

  FastPacketChannel._(
    this.remoteAddress,
    this.remotePort,
    this._pipe,
  ) {
    _pipe.onEvent(receive);
  }

  @override
  void add(Packet packet) {
    _pipe.add(packet);
  }

  @override
  void addAll(Iterable<Packet> packets) {
    packets.forEach(add);
  }

  @override
  void receive(Packet packet) {
    emitAll([
      packet,
      Packet.end(packet.address, packet.port),
    ]);
  }
}
