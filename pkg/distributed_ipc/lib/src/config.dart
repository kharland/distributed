import 'dart:async';

import 'package:distributed.ipc/src/node_connection.dart';
import 'package:distributed.ipc/src/socket.dart';

ConnectionProvider connectionProvider;

void setConnectionProvider(ConnectionProvider value) {
  assert(connectionProvider == null, '$ConnectionProvider already initialized');
  connectionProvider = value;
}

abstract class ConnectionProvider {
  Future<Socket> tcp(NodeConnectionConfig config);

  Future<Socket> udp(NodeConnectionConfig config);
}
