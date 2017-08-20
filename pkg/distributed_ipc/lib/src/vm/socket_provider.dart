import 'dart:async';

import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/platform/vm.dart';
import 'package:distributed.ipc/src/config.dart';
import 'package:distributed.ipc/src/vm/vm_socket.dart';

class VmSocketProvider implements SocketProvider {
  const VmSocketProvider();

  @override
  Future<Socket> udp(UdpSocketConfig config) async {
    return UdpSocket.connect(config);
  }

  @override
  Future<Socket> tcp(address, int port) {
    return VmSocket.connect(address, port);
  }
}
