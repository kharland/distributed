import 'dart:async';

import 'package:distributed/interfaces/event.dart';
import 'package:distributed/interfaces/node.dart';
import 'package:distributed/interfaces/peer.dart';

import 'package:distributed/src/networking.dart';
import 'package:meta/meta.dart';

class ServerNode implements Node {
  @override
  @virtual
  final String name;

  @override
  @virtual
  final String hostname;

  @override
  @virtual
  final String cookie;

  ConnectionRequestHandler _connectionRequestHandler;

  ServerNode(this.name, this.hostname, this.cookie,
      [int port = Node.DEFAULT_PORT]) {
    _connectionRequestHandler =
        new ConnectionRequestHandler(cookie, hostname, port);
    _connectionRequestHandler.onConnection((ConnectionEvent event) {
      // Handshake
    });
  }

  @override
  Future<bool> connect(String name, String hostname) {}

  @override
  Future<bool> disconnect(String name, String hostname) {}

  @override
  bool get isHidden => null;

  @override
  Stream<ConnectionEvent> get onConnect => null;

  @override
  Stream<DisconnectionEvent> get onDisconnect => null;

  @override
  Stream<String> get onMessage => null;

  @override
  List<Peer> get peers => null;

  @override
  void receive(MessageFilter filter, MessageHandler handler) {}

  @override
  Future<Null> send(String message, Peer peer) {}

  @override
  Future<Null> shutdown() async {
    await _connectionRequestHandler.close();
  }
}
