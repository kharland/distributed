import 'dart:async';

import 'package:distributed.http/src/testing/local_address.dart';
import 'package:distributed.http/src/testing/network_agents.dart';
import 'package:distributed.http/vm.dart';

class AddressReleaser {
  final String host;
  final int port;
  final NetworkEmulator emu;

  AddressReleaser(this.host, this.port, this.emu);

  void release() {
    emu.release(host, port);
  }
}

class NetworkEmulator {
  List<NetworkAddress> _addresses;

  NetworkEmulator(this._addresses);

  Stream<Socket> listen(String host, [int port]) {
    var address = _findAddressOrFail(host);
    var agent = new ListeningAgent(new AddressReleaser(host, port, this));
    address.attach(agent);
    return agent.sockets;
  }

  Socket connectWithoutSrcPort(String srcHost, String destHost, int destPort) {
    var srcPort = _findAddressOrFail(srcHost).getFreePort();
    return connect(srcHost, srcPort, destHost, destPort);
  }

  Socket connect(String srcHost, int srcPort, String destHost, int destPort) {
    var srcAddress = _findAddressOrFail(srcHost);
    var destAddress = _findAddressOrFail(destHost);
    var connectingAgent =
        new ConnectingAgent(new AddressReleaser(srcHost, srcPort, this));
    srcAddress.attach(connectingAgent);
    return destAddress.connect(connectingAgent, destPort);
  }

  void release(String host, int port) {
    var address = _findAddressOrFail(host);
    address.detach(address.agents.firstWhere((a) => a.port == port));
  }

  /// Returns the [NetworkAddress] whose host is [host].
  ///
  /// If no address is found, a [SocketException] is raised.
  NetworkAddress _findAddressOrFail(String host) =>
      _addresses.firstWhere((a) => a.host == host,
          orElse: () => throw new SocketException('Address not found "$host"'));
}
