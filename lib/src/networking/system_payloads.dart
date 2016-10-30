import 'dart:convert';

import 'package:distributed/interfaces/peer.dart';

/// A JSON compatible object that can be passed between nodes.
///
/// Each message should define a constructor to recreate itself from its
/// JSON representation.
abstract class Payload {
  final Peer sender;

  Payload._(this.sender);

  /// Converts this [Payload] to a JSON compatible format.
  Map<String, Object> toJson();

  @override
  String toString() => '$runtimeType ${JSON.encode(toJson())}';
}

/// A [Payload] containing information about a peer and it's connected peers.
class NetworkInfo extends Payload {
  /// The collection of peers connected to [Peer].
  final Iterable<Peer> connectedPeers;

  NetworkInfo(Peer sender, this.connectedPeers) : super._(sender);

  static NetworkInfo fromJson(Map<String, Object> json) {
    var connectedPeers =
        json['connectedPeers'] as Iterable<Map<String, Object>>;
    return new NetworkInfo(
        new Peer.fromJson(json['peer'] as Map<String, Object>),
        connectedPeers.map((p) => new Peer.fromJson(p)));
  }

  static NetworkInfo fromJsonString(String json) =>
      NetworkInfo.fromJson(JSON.decode(json) as Map<String, Object>);

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) =>
      other is NetworkInfo && other.hashCode == hashCode;

  @override
  Map<String, Object> toJson() => <String, Object>{
        'peer': sender.toJson(),
        'connectedPeers': connectedPeers.map((peer) => peer.toJson()).toList()
      };
}

class ConnectionRequest extends Payload {
  final String cookie;

  ConnectionRequest(Peer sender, [this.cookie = '']) : super._(sender);

  static ConnectionRequest fromJson(Map<String, Object> json) =>
      new ConnectionRequest(
          new Peer.fromJson(json['sender'] as Map<String, Object>),
          json['cookie']);

  static ConnectionRequest fromJsonString(String json) =>
      ConnectionRequest.fromJson(JSON.decode(json) as Map<String, Object>);

  @override
  Map<String, Object> toJson() =>
      <String, Object>{'sender': sender.toJson(), 'cookie': cookie};
}
