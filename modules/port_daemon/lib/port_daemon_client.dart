import 'dart:async';

import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:distributed.port_daemon/src/http_daemon_client.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:meta/meta.dart';

/// An object for communicating with a [PortDaemon].
abstract class PortDaemonClient {
  factory PortDaemonClient({@required HostMachine daemonHostMachine}) =
      HttpDaemonClient;

  /// The [HostMachine] where this client's [PortDaemon] is running.
  HostMachine get daemonHostMachine;

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

  /// Instructs the daemon server to register [nodeName] under a new port.
  ///
  /// Returns a Future that completes with the new port if registration
  /// succeeded or [Ports.error] if it failed.
  Future<int> register(String nodeName);

  /// Instructs the daemon server to deregister [nodeName].
  ///
  /// Returns a future that completes with true iff deregistration succeeded.
  Future<bool> deregister(String nodeName);
}
