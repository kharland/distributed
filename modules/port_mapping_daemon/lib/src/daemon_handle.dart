import 'package:distributed.port_mapping_daemon/daemon.dart';
import 'package:meta/meta.dart';

class DaemonHandle {
  final String hostname;
  final String cookie;
  final int port;

  @literal
  const DaemonHandle(this.hostname, this.port, this.cookie);

  String get url => 'ws://$hostname:$port';
}

const defaultHandle = const DaemonHandle(
    PortMappingDaemon.defaultHost,
    PortMappingDaemon.defaultPort,
    PortMappingDaemon.defaultCookie,
    );
