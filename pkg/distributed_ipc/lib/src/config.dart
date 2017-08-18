import 'dart:async';

import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/socket.dart';

abstract class SocketProvider {
  Future<Socket> tcp(address, int port);

  Future<Socket> udp(DatagramSocketConfig config);
}
