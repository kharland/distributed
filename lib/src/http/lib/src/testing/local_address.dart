import 'package:distributed.http/src/testing/network_agents.dart';
import 'package:distributed.http/vm.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:meta/meta.dart';

class NetworkAddress {
  final String host;
  final Logger _logger;

  @visibleForTesting
  final List<NetworkAgent> agents = <NetworkAgent>[];

  NetworkAddress(this.host, this._logger);

  bool isReserved(int port) => agents.any((a) => a.port == port);

  void attach(NetworkAgent agent) {
    if (isReserved(agent.port)) {
      throw new SocketException('Port is in use');
    }
    agents.add(agent);
    _logger
      ..pushPrefix('$NetworkAddress')
      ..log("Attached agent ${agent.releaser}")
      ..popPrefix();
  }

  void detach(NetworkAgent agent) {
    assert(agents.contains(agent));
    agents.remove(agent);
    if (agent is ListeningAgent) {
      agent.close();
    }
    _logger
      ..pushPrefix('$NetworkAddress')
      ..log("Detatched agent ${agent.releaser}")
      ..popPrefix();
  }

  Socket connect(ConnectingAgent connectingAgent, int port) {
    var receiver =
        agents.firstWhere((na) => na.port == port, orElse: () => null);
    if (receiver != null && receiver is ListeningAgent) {
      var socket = receiver.accept(connectingAgent);
      _logger
        ..pushPrefix('$NetworkAddress')
        ..log("Connected ${connectingAgent.releaser} to ${receiver.releaser}")
        ..popPrefix();
      return socket;
    } else {
      throw new SocketException('Connection refused');
    }
  }

  int getFreePort() {
    int nextPort = 1;
    while (agents.any((a) => a.port == nextPort)) {
      nextPort++;
    }
    return nextPort;
  }
}

class SocketException implements Exception {
  final String message;

  SocketException(this.message);

  @override
  String toString() => 'SocketException: $message';
}
