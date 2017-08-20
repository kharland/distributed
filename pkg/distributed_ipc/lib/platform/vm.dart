import 'dart:async';

import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/config.dart';
import 'package:distributed.ipc/src/vm/vm_socket.dart';

class VmSocketProvider implements SocketProvider {
  @override
  Future<Socket> udp(DatagramSocketConfig config) async {
    return VmDatagramSocket.connect(config);
  }

  @override
  Future<Socket> tcp(address, int port) {
    return VmSocket.connect(address, port);
  }
}
