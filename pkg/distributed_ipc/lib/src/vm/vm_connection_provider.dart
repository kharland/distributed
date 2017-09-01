import 'dart:async';
import 'package:distributed.ipc/src/config.dart';
import 'package:distributed.ipc/src/socket.dart';
import 'package:distributed.ipc/src/node_connection.dart';

class VmConnectionProvider implements ConnectionProvider {
  @override
  Future<Socket> tcp(NodeConnectionConfig config) {}

  @override
  Future<Socket> udp(NodeConnectionConfig config) {}
}
