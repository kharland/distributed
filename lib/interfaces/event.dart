import 'peer.dart';

class ConnectionEvent {
  final Peer peer;

  const ConnectionEvent(this.peer);
}

class DisconnectionEvent {
  final Peer peer;

  const DisconnectionEvent(this.peer);
}
