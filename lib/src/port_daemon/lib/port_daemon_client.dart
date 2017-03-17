import 'dart:async';

import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:distributed.port_daemon/src/http_daemon_client.dart';
import 'package:distributed.port_daemon/ports.dart';
import 'package:meta/meta.dart';

/// An object for communicating with a [PortDaemon].
abstract class PortDaemonClient {
  factory PortDaemonClient({
    @required String name,
    @required BuiltHostMachine daemonHostMachine,
    Logger logger,
  }) = HttpDaemonClient;

  /// The [BuiltHostMachine] where this client's [PortDaemon] is running.
  BuiltHostMachine get daemonHostMachine;

  /// Completes with true iff a daemon is running at [daemonHostMachine].
  Future<bool> get isDaemonRunning;

  /// Returns a mapping of node names to their registered ports.
  ///
  /// Returns an empty map if no nodes are registered or if an error occurred.
  Future<Map<String, int>> getNodes();

  /// Request the port for the node named [nodeName].
  ///
  /// Returns [Ports.error] if no such node is registered with the daemon.
  Future<int> lookup(String nodeName);

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
