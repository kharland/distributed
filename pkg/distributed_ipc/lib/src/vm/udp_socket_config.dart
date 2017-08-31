import 'package:distributed.ipc/src/protocol/transfer_type.dart';
import 'package:meta/meta.dart';

/// Configuration options for a [UdpSocket].
class UdpSocketConfig {
  /// The algorithm to use when sending data over the socket.
  final TransferType transferType;

  /// The local address to bind to.
  final String address;

  /// The local port to bind to.
  final int port;

  @literal
  const UdpSocketConfig({
    @required this.transferType,
    @required this.address,
    @required this.port,
  });
}
