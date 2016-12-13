import 'package:distributed/src/port_mapping_daemon/daemon.dart';
import 'package:meta/meta.dart';

class DaemonInfo {
  final String hostname;
  final String cookie;
  final int port;

  @literal
  const DaemonInfo(this.hostname, this.port, this.cookie);

  String get url => 'ws://$hostname:$port';
}

const defaultPmdInfo = const DaemonInfo(
  PortMappingDaemon.defaultHost,
  PortMappingDaemon.defaultPort,
  PortMappingDaemon.defaultCookie,
);
