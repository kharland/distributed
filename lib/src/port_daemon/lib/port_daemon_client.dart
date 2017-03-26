import 'dart:async';

import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.objects/interfaces.dart';
import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:distributed.port_daemon/ports.dart';
import 'package:distributed.port_daemon/src/http_daemon_client.dart';
import 'package:meta/meta.dart';

class PortDaemonClientFactory {
  final Logger _logger;

  PortDaemonClientFactory(this._logger);

  PortDaemonClient createClient(String name, HostMachine remoteHost) =>
      new PortDaemonClient(name: name, logger: _logger, remoteHost: remoteHost);
}

/// An object for communicating with a [PortDaemon].
abstract class PortDaemonClient {
  factory PortDaemonClient({
    @required String name,
    @required HostMachine remoteHost,
    Logger logger,
  }) = HttpDaemonClient;
  
  /// The [HostMachine] where this client's [PortDaemon] is running.
  HostMachine get remoteHost;

  /// Completes with true iff a daemon is running at [remoteHost].
  Future<bool> get isDaemonRunning;

  /// Returns a mapping of node names to their registered ports.
  ///
  /// Returns an empty map if no nodes are registered or if an error occurred.
  Future<Map<String, int>> getNodes();

  /// Request the url for connecting to the node named [nodeName].
  ///
  /// Returns the empty string if [nodeName] could not be found.
  Future<String> lookup(String nodeName);

  /// Instructs the daemon server to register this client under a new port.
  ///
  /// Returns a Future that completes with the new port if registration
  /// succeeded or [Ports.error] if it failed.
  Future<int> register();

  /// Instructs the daemon server to deregister this client.
  ///
  /// Returns a future that completes with true iff deregistration succeeded.
  Future<bool> deregister();
}
