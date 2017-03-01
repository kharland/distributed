import 'dart:async';

import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:distributed.port_daemon/src/http_daemon.dart';

abstract class PortDaemon {
  factory PortDaemon({HostMachine hostMachine}) = ExpressHttpDaemon;

  /// The set of names of all nodes registered with this daemon.
  Set<String> get nodes;

  /// The url for connecting to this daemon.
  String get url;

  /// The number of milliseconds that may pass between successive calls to
  /// [keepAlive] before this daemon automatically deregisters the corresponding
  /// node.
  int get heartbeatMs;

  /// Signals to this daemon that [nodeName] is still available.
  void keepAlive(String nodeName);

  /// Starts listening for requests.
  ///
  /// Returns a future that completes when the server is ready for connections.
  Future start();

  /// Stops listening for new connections.
  void stop();

  /// Assigns a port to a new [nodeName].
  ///
  /// Returns a future that completes with the port number.
  Future<int> registerNode(String nodeName);

  /// Frees the port held by node [nodeName].
  ///
  /// An argument error is thrown if such a node does not exist.
  Future deregisterNode(String nodeName);

  /// Returns the port for [nodeName].
  ///
  /// If no node is found, returns [Ports.error].
  Future<int> lookupPort(String nodeName);
}
