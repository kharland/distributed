import 'dart:io' as io;

import 'package:distributed.ipc/src/protocol/transfer_type.dart';
import 'package:meta/meta.dart';

/// Configuration options for a [UdpSocket].
class UdpSocketConfig {
  /// Describes
  final TransferType transferMode;
  final io.InternetAddress address;
  final int port;

  @literal
  const UdpSocketConfig({
    @required this.transferMode,
    @required this.address,
    @required this.port,
  });
}
