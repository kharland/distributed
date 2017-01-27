import 'dart:async';

import 'package:distributed.node/src/connection/connection.dart';
import 'package:distributed.node/src/connection/connection_channels.dart';
import 'package:distributed.node/src/message/message.dart';
import 'package:distributed.node/src/node_finder.dart';
import 'package:distributed.node/src/peer.dart';
import 'package:distributed.node/src/peer_identification_strategy.dart';
import 'package:distributed.port_daemon/src/ports.dart';

abstract class ConnectionStrategy {
  Stream<Connection> connect(String localPeerName, String remotePeerName);
}

class TransitiveConnectionStrategy implements ConnectionStrategy {
  final ConnectionStrategy _connectionStrategy;
  final List<Peer> _connectedPeers;

  TransitiveConnectionStrategy(this._connectedPeers, this._connectionStrategy);

  @override
  Stream<Connection> connect(String localPeerName, String remotePeerName) {
    var streamController = new StreamController<Connection>();
    _connect(localPeerName, remotePeerName, streamController, _connectedPeers);
    return streamController.stream;
  }

  Future _connect(
    String localPeerName,
    String remotePeerName,
    StreamController<Connection> controller,
    List<Peer> connectedPeers,
  ) async {
    _connectionStrategy
        .connect(localPeerName, remotePeerName)
        .forEach((Connection connection) {
      controller.add(connection);
      connectedPeers.add(connection.peer);

      var transitivePeers = <Peer>[]; // Request list of peers from peer.
      transitivePeers.forEach((Peer peer) {
        if (!connectedPeers.contains(peer)) {
          _connect(localPeerName, peer.name, controller, connectedPeers);
        }
      });
    });
  }
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
          connection.channels.system.sink, connection.channels.system.stream);
      assert(verifiedPeerName == remotePeerName);
      return connection;
    });
  }
}

class SearchForNode implements ConnectionStrategy {
  final NodeFinder _nodeFinder;
  final ConnectionChannelsProvider<Message> _channelsProvider;

  SearchForNode(this._nodeFinder, this._channelsProvider);

  @override
  Stream<Connection> connect(String localPeerName, String remotePeerName) =>
      _connect(localPeerName, remotePeerName).asStream();

  Future<Connection> _connect(String localPeerName, remotePeerName) async {
    assert(remotePeerName.isNotEmpty);
    var remotePeerAddress = await _nodeFinder.findNodeAddress(remotePeerName);
    if (remotePeerAddress.isEmpty) {
      throw new Exception('node not found $remotePeerName');
    }

    int remotePeerPort = await _nodeFinder.findNodePort(remotePeerName);
    if (remotePeerPort == Ports.invalidPort.toInt()) {
      throw new Exception('node not found $remotePeerName');
    }

    var remotePeerUrl = 'ws://$remotePeerAddress:$remotePeerPort';
    return new Connection(
      new Peer(remotePeerName, remotePeerAddress),
      await _channelsProvider.createFromUrl(remotePeerUrl),
    );
  }
}
