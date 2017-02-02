import 'dart:io';

import 'package:distributed.net/secret.dart';
import 'package:distributed.port_daemon/daemon_server.dart';

import 'package:fixnum/fixnum.dart';

/// A class for specifying the location of a [DaemonServer].
class DaemonServerInfo {
  static final InternetAddress defaultAddress = InternetAddress.ANY_IP_V4;
  static final Int64 defaultPort = new Int64(4369);

  final InternetAddress address;
  final Int64 port;
  final Secret secret;

  DaemonServerInfo({InternetAddress address, Int64 port, Secret secret})
      : address = address ?? defaultAddress,
        port = port ?? defaultPort,
        secret = secret ?? Secret.acceptAny;

  String get url => 'http://${address.address}:$port';
}
