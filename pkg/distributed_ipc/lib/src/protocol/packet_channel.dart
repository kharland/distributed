import 'package:distributed.ipc/platform/vm.dart';
import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/protocol/packet_codec.dart';
import 'package:distributed.ipc/src/typedefs.dart';
import 'package:meta/meta.dart';

/// An I/O channel for transferring [Packets] between processes.
///
/// A [PacketChannel] consumes [Iterable]s of [Packet]s from the local client
/// and sends them over the network.  It consumes encoded [Packet] data from the
/// network and broadcasts the decoded [Packet]s locally.
abstract class PacketChannel implements EventBus<Packet> {
  static const DefaultCodec = const Utf8PacketCodec();

  /// Creates a [PacketChannel].
  ///
  /// [config] is the [PacketChannelConfig] to create the channel from.
  /// [writeData] is a callback for writing packet data to the remote peer.
  factory PacketChannel.fromConfig(
    PacketChannelConfig config, {
    @required Consumer<List<int>> writeData,
  }) {
    switch (config.transferType) {
      case TransferType.FAST:
        return new FastPacketChannel.fromConfig(config, writeData);
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

  /// Receives the [encodedPacket] sent from [remoteAddress] and [remotePort].
  void receive(Iterable<int> encodedPacket);
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
  final _eventBusController = new EventBusController<Packet>();

  /// Sink for outgoing data.
  final Consumer<List<int>> _write;

  @override
  final String remoteAddress;

  @override
  final int remotePort;

  final PacketCodec _codec;

  FastPacketChannel.fromConfig(
      PacketChannelConfig config, Consumer<List<int>> write)
      : this(
          config.address,
          config.port,
          write,
          new PacketCodec.fromEncoding(config.encodingType),
        );

  FastPacketChannel(
    this.remoteAddress,
    this.remotePort,
    this._write, [
    this._codec = PacketChannel.DefaultCodec,
  ]);

  @override
  void add(Packet packet) {
    _write(_codec.encode(packet));
  }

  @override
  void addAll(Iterable<Packet> packets) {
    packets.forEach(add);
  }

  @override
  void receive(Iterable<int> encodedPacket) {
    final packet = _codec.decode(encodedPacket);
    _eventBusController.addAllEvents([
      packet,
      Packet.end(packet.address, packet.port),
    ]);
  }

  @override
  void onEvent(Consumer<Packet> consumer) {
    _eventBusController.onEvent(consumer);
  }
}
