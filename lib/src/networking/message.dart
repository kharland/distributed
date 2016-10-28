import 'dart:typed_data';

import 'package:distributed/interfaces/peer.dart';
import 'package:distributed/src/networking/json.dart';
import 'package:meta/meta.dart';

/// A JSON compatible object that can be passed between nodes.
///
/// Each message should define a constructor to recreate itself from its
/// JSON representation.
abstract class Message {
  Peer get sender;

  /// Converts this [Message] to a JSON compatible format.
  Map<String, Object> toJson();

  @override
  String toString() => '$runtimeType ${serialize()}';

  /// Encodes this message as a JSON string.
  String serialize() => Json.encode(toJson());
}

/// A [Message] containing informatino about a peer and it's connected peers.
class PeerInfoMessage extends Message {
  /// The [Peer] this message describes.
  @override
  @virtual
  final Peer sender;

  /// The collection of peers connected to [Peer].
  final Iterable<Peer> connectedPeers;

  /// Default constructor.
  PeerInfoMessage(this.sender, this.connectedPeers);

  /// Creates a [PeerInfoMessage] from a JSON map.
  factory PeerInfoMessage.fromJson(Map<String, Object> json) {
    var connectedPeers =
        json['connectedPeers'] as Iterable<Map<String, Object>>;
    return new PeerInfoMessage(
        new Peer.fromJson(json['peer'] as Map<String, Object>),
        connectedPeers.map((p) => new Peer.fromJson(p)));
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) =>
      other is PeerInfoMessage && other.hashCode == hashCode;

  @override
  Map<String, Object> toJson() => <String, Object>{
        'peer': sender.toJson(),
        'connectedPeers': connectedPeers.map((peer) => peer.toJson()).toList()
      };
}

/// A request to connect with a [Peer].
///
/// The request is a json string with the following format:
///
///      {
///        'cookie': String,
///        'peer': Peer,
///      }
class ConnectMessage extends Message {
  final String cookie;
  final Peer peer;

  @override
  @virtual
  final Peer sender;

  ConnectMessage(this.cookie, this.sender, this.peer);

  /// Constructs a [ConnectMessage] from its json format.
  factory ConnectMessage.fromJson(Map<String, Object> json) =>
      new ConnectMessage(
          json['cookie'],
          new Peer.fromJson(json['sender'] as Map<String, Object>),
          new Peer.fromJson(json['peer'] as Map<String, Object>));

  /// Constructs a [ConnectMessage] from a [String] or a [ByteBuffer];
  factory ConnectMessage.fromString(String json) =>
      new ConnectMessage.fromJson(Json.decode(json));

  @override
  Map<String, Object> toJson() => <String, Object>{
        'cookie': cookie,
        'sender': sender.toJson(),
        'peer': peer.toJson()
      };
}
