import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/protocol.dart';
import 'package:distributed.ipc/src/transfer_type.dart';
import 'package:meta/meta.dart';

/// Describes how a [Connection] should be created.
@immutable
class ConnectionConfig {
  /// The protocol-specific settings to use for the connection.
  ///
  /// The default is [UdpConfig] with default settings.
  final ProtocolConfig protocolConfig;

  /// The address to connect to.
  final String remoteAddress;

  /// The port to connect to.
  final int remotePort;

  @literal
  const ConnectionConfig({
    @required this.remoteAddress,
    @required this.remotePort,
    this.protocolConfig: const UdpConfig(),
  });
}

/// The protocol configuration to use for a [ConnectionConfig].
abstract class ProtocolConfig {
  /// The protocol to use.
  Protocol get protocol;
}

/// A TCP protocol configuration.
class TcpConfig implements ProtocolConfig {
  Protocol get protocol => Protocol.tcp;
}

/// A UDP protocol configuration.
class UdpConfig implements ProtocolConfig {
  /// The datagram transfer algorithm to use for the connection.
  ///
  /// The default is [TransferType.FAST].
  final TransferType transferType;

  /// The encoding type to use for the connection.
  ///
  /// The default is [EncodingType.UTF8].
  final EncodingType encodingType;

  Protocol get protocol => Protocol.upd;

  const UdpConfig({
    this.transferType: TransferType.FAST,
    this.encodingType: EncodingType.UTF8,
  });
}
