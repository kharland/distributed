import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:distributed.ipc/src/udp/datagram_socket.dart';
import 'package:distributed.ipc/src/udp/transfer_type.dart';

/// Specifies the settings necessary to create a [DatagramChannel].
class DatagramChannelConfig {
  final String remoteAddress;
  final int remotePort;
  final DatagramSocket socket;
  final TransferType transferType;
  final EncodingType encodingType;

  DatagramChannelConfig.fromDatagram(GreetDatagram dg, DatagramSocket socket)
      : this(dg.address, dg.port, socket,
            transferType: new TransferType.fromValue(dg.transferType),
            encodingType: new EncodingType.fromValue(dg.encodingType));

  DatagramChannelConfig(
    this.remoteAddress,
    this.remotePort,
    this.socket, {
    this.transferType: TransferType.FAST,
    this.encodingType: EncodingType.UTF8,
  });
}
