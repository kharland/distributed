import 'dart:async';

import 'package:distributed.node/src/connection/connection.dart';
import 'package:distributed.node/src/connection/connection_channels.dart';
import 'package:distributed.node/src/peer_identification_strategy.dart';
import 'package:distributed.node/src/message/message.dart';
import 'package:distributed.node/src/node_finder.dart';
import 'package:distributed.node/src/peer.dart';

abstract class ConnectionStrategy<T> {
  Future<Connection<T>> connect(String localPeerName, String remotePeerName);
}

class RequireIdentification implements ConnectionStrategy<Message> {
  ConnectionStrategy<Message> _connectionStrategy;
  PeerIdentificationStrategy _identificationStrategy;

  RequireIdentification(this._connectionStrategy, this._identificationStrategy);

  @override
  Future<Connection<Message>> connect(
    String localPeerName,
    String remotePeerName,
  ) async {
    var connection = await _connectionStrategy.connect(
      localPeerName,
      remotePeerName,
    );
    var verifiedPeerName = await _identificationStrategy.identifyRemote(
      connection.channels.system.sink,
      connection.channels.system.stream,
    );
    assert(verifiedPeerName == remotePeerName);
    return connection;
  }
}

class SearchForNode<T> implements ConnectionStrategy<T> {
  final NodeFinder _nodeFinder;
  final ConnectionChannelsProvider<T> _channelsProvider;

  SearchForNode(this._nodeFinder, this._channelsProvider);

  @override
  Future<Connection<T>> connect(
    String localPeerName,
    String remotePeerName,
  ) async {
    assert(remotePeerName.isNotEmpty);
    var remotePeerAddress = await _nodeFinder.findNodeAddress(remotePeerName);
    if (remotePeerAddress.isEmpty) {
      throw new Exception('node not found $remotePeerName');
    }

    var remotePeerPort = await _nodeFinder.findNodePort(remotePeerName);
    if (remotePeerPort == -1) {
      throw new Exception('node not found $remotePeerName');
    }

    var remotePeerUrl = 'ws://$remotePeerAddress:$remotePeerPort';
    return new Connection(
      new Peer(remotePeerName, remotePeerAddress),
      await _channelsProvider.createFromUrl(remotePeerUrl),
    );
  }
}
