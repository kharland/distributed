import 'dart:io' as io;

import 'package:distributed.ipc/src/protocol/transfer_mode.dart';
import 'package:meta/meta.dart';

class DatagramSocketConfig {
  final TransferMode transferMode;
  final io.InternetAddress address;
  final int port;

  @literal
  const DatagramSocketConfig({
    @required this.transferMode,
    @required this.address,
    @required this.port,
  });
}
