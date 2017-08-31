import 'dart:async';

import 'package:distributed.ipc/platform/vm.dart';
import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/protocol/packet_channel.dart';
import 'package:distributed.ipc/src/protocol/packet_codec.dart';

// FIXME: support encryption type.
abstract class ConnectionHost {
  static const ROUTER_ID = 100;

  final _channelsController = new StreamController<PacketChannel>(sync: true);

  ConnectionHost(Stream<GreetingPacket> packets) {}

  Stream<PacketChannel> get channels => null;

  /// Creates a new [PacketChannel] connected to [address] and [port].
  ///
  /// [encodingType] is the [EncodingType] to use on the channel.
  /// [transferType] is the [TransferType] to use on t
  Future<PacketChannel> open(
    String address,
    int port, {
    EncodingType encodingType,
    TransferType transferType,
  }) async {
    final codec = new PacketCodec.fromEncoding(encodingType);
    final greeting = new GreetingPacket(
      address,
      port,
      encodingType: encodingType.value,
      transferType: transferType.value,
    );

    final channel = new PacketChannel.fromTransferType(
        transferType,
        new PacketChannelConfig(
          codec,
          address,
          port,
        ));

    channel.send([greeting]);

    return channel;
  }

  /// Closes this connection host.
  ///
  /// No more channels can be created at this host after calling this method.
  void close() {
    _channelsController.close();
  }

  /// Attempts to open a new [PacketChannel] configured from [greeting].
  void _handleGreeting(GreetingPacket greeting) {
    try {
      final codec = new PacketCodec.fromEncoding(
          new EncodingType.fromValue(greeting.encodingType));
      final transferType = new TransferType.fromValue(greeting.transferType);

      // Send acceptance of greeting to remote.

      final channel = new PacketChannel.fromTransferType(
          transferType,
          new PacketChannelConfig(
            codec,
            greeting.address,
            greeting.port,
          ));
      _channelsController.add(channel);
    } catch (error) {
      // FIXME log exception
    }
  }
}
