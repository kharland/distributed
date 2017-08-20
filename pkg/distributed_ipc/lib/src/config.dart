import 'dart:async';

import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/platform/vm.dart';
import 'package:distributed.ipc/src/socket.dart';

SocketProvider provider;

void setSocketProvider(SocketProvider value) {
  assert(provider == null, 'SocketProvider is already initialized');
  provider = value;
}

abstract class SocketProvider {
  Future<Socket> tcp(address, int port);

  Future<Socket> udp(UdpSocketConfig config);
}
