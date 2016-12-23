import 'dart:convert';

import 'package:distributed.node/interfaces/peer.dart';

/// A message containing information about a peer and it's connected peers.
class NetworkInfo {
  /// The collection of peers connected to [Peer].
  final Iterable<Peer> connectedPeers;

  NetworkInfo(this.connectedPeers);

  static NetworkInfo fromJson(Map<String, Object> json) {
    var connectedPeers =
        json['connectedPeers'] as Iterable<Map<String, Object>>;
    return new NetworkInfo(connectedPeers.map((p) => new Peer.fromJson(p)));
  }

  static NetworkInfo fromJsonString(String json) =>
      NetworkInfo.fromJson(JSON.decode(json) as Map<String, Object>);

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) =>
      other is NetworkInfo && other.hashCode == hashCode;

  Map<String, Object> toJson() => <String, Object>{
        'connectedPeers': connectedPeers.map((peer) => peer.toJson()).toList()
      };

  String toJsonString() => JSON.encode(toJson());
}

class ConnectionRequest {
  final String cookie;

  ConnectionRequest([this.cookie = '']);

  static ConnectionRequest fromJson(Map<String, Object> json) =>
      new ConnectionRequest(json['cookie']);

  static ConnectionRequest fromJsonString(String json) =>
      ConnectionRequest.fromJson(JSON.decode(json) as Map<String, Object>);

  Map<String, Object> toJson() => {'cookie': cookie};

  String toJsonString() => JSON.encode(toJson());
}
