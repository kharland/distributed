import 'dart:async';

import 'package:distributed.ipc/platform/vm.dart';
import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/protocol/packet_channel.dart';
import 'package:distributed.ipc/src/protocol/packet_codec.dart';
import 'package:distributed.ipc/src/protocol/typed_datagram.dart';
import 'package:distributed.ipc/src/protocol/typed_datagram_adapter.dart';

// FIXME: support encryption type.
abstract class ConnectionHost {
  /// Used to encode GREET packets.
  static const _greetCodec = const Utf8PacketCodec();

  final TypedDatagramAdapter _typedDatagramAdapter;

  ConnectionHost(this._typedDatagramAdapter);

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
    // Create packet channel at remote host by sending GREET packet with channel
    // information.
    final greeting = new GreetPacket(
      address,
      port,
      encodingType: encodingType.value,
      transferType: transferType.value,
    );

    _typedDatagramAdapter.add(new TypedDatagram(
      _greetCodec.encode(greeting),
      address,
      port,
      DatagramType.GREET,
    ));

    final channelCodec = new PacketCodec.fromEncoding(encodingType);
    final channel = new PacketChannel.fromTransferType(
      transferType,
      new PacketChannelConfig(channelCodec, address, port),
    );

    // Filter datagrams sent from the new channel's remote partner.
    _typedDatagramAdapter.addDatagramHandler((TypedDatagram datagram) {
      if (datagram.address == address && datagram.port == port) {
        channel.receive(channelCodec.decode(datagram.data));
      }
    });

    return channel;
  }

  /// Attempts to open a new [PacketChannel] configured from [greeting].
  void _handleGreeting(GreetPacket greeting) {
    try {
      final codec = new PacketCodec.fromEncoding(
          new EncodingType.fromValue(greeting.encodingType));
      final transferType = new TransferType.fromValue(greeting.transferType);

      //TODO: Send acceptance of greeting to remote.

      final channel = new PacketChannel.fromTransferType(
          transferType,
          new PacketChannelConfig(
            codec,
            greeting.address,
            greeting.port,
          ));
    } catch (error) {
      // FIXME log exception
    }
  }
}
