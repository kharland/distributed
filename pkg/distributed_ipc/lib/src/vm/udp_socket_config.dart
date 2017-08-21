import 'dart:io' as io;

import 'package:distributed.ipc/src/protocol/transfer_type.dart';
import 'package:meta/meta.dart';

/// Configuration options for a [UdpSocket].
class UdpSocketConfig {
  /// The algorithm to use when sending data over the socket.
  final TransferType transferMode;

  /// The address to connect to.
  final io.InternetAddress address;

  /// The port to connect to.
  final int port;

  @literal
  const UdpSocketConfig({
    @required this.transferMode,
    @required this.address,
    @required this.port,
  });
}
