import 'dart:async';

import 'package:distributed.connection/connection.dart';
import 'package:distributed.connection/src/data_channels.dart';
import 'package:distributed.node/src/node_finder.dart';
import 'package:distributed.node/src/peer_identification_strategy.dart';
import 'package:distributed.port_daemon/src/ports.dart';

abstract class ConnectionStrategy {
  Stream<Connection> connect(String localPeerName, String remotePeerName);
}

class RequireIdentification implements ConnectionStrategy {
  ConnectionStrategy _connectionStrategy;
  PeerIdentificationStrategy _identificationStrategy;

  RequireIdentification(this._connectionStrategy, this._identificationStrategy);

  @override
  Stream<Connection> connect(String localPeerName, String remotePeerName) {
    var stream = _connectionStrategy.connect(localPeerName, remotePeerName);
    return stream.asyncMap((Connection connection) async {
      var verifiedPeerName = await _identificationStrategy.identifyRemote(
          connection.system.sink, connection.system.stream);
      assert(verifiedPeerName == remotePeerName);
      return connection;
    });
  }
}

class SearchForNode implements ConnectionStrategy {
  final NodeFinder _nodeFinder;
  final DataChannelsProvider<String> _channelsProvider;

  SearchForNode(this._nodeFinder, this._channelsProvider);

  @override
  Stream<Connection> connect(String localPeerName, String remotePeerName) =>
      _connect(localPeerName, remotePeerName).asStream();

  Future<Connection> _connect(String localPeerName, remotePeerName) async {
    assert(remotePeerName.isNotEmpty);
    var remotePeerAddress = await _nodeFinder.findNodeAddress(remotePeerName);
    if (remotePeerAddress == null) {
      throw new Exception('node not found $remotePeerName');
    }

    int remotePeerPort = await _nodeFinder.findNodePort(remotePeerName);
    if (remotePeerPort == Ports.invalidPort.toInt()) {
      throw new Exception('node not found $remotePeerName');
    }

    var remotePeerUrl = 'ws://$remotePeerAddress:$remotePeerPort';
    return new Connection(await _channelsProvider.createFromUrl(remotePeerUrl));
  }
}
