import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/protocol.dart';
import 'package:distributed.ipc/src/udp/transfer_type.dart';
import 'package:meta/meta.dart';

/// Describes how a [Connection] should be created.
@immutable
class ConnectionConfig {
  final ProtocolConfig protocolConfig;
  final String localAddress;
  final int localPort;
  final String remoteAddress;
  final int remotePort;

  @literal
  const ConnectionConfig({
    @required this.localAddress,
    @required this.localPort,
    @required this.remoteAddress,
    @required this.remotePort,
    this.protocolConfig: const UdpConfig(),
  });
}

abstract class ProtocolConfig {
  Protocol get protocol;
}

class TcpConfig implements ProtocolConfig {
  Protocol get protocol => Protocol.tcp;
}

class UdpConfig implements ProtocolConfig {
  final TransferType transferType;
  final EncodingType encodingType;

  Protocol get protocol => Protocol.upd;

  const UdpConfig({
    this.transferType: TransferType.FAST,
    this.encodingType: EncodingType.UTF8,
  });
}
