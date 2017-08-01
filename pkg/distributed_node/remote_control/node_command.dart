import 'dart:async';

import 'package:distributed/distributed.dart';

/// A command that a [Node] take a particular action.
abstract class NodeCommand {
  /// Executes this command on [node].
  Future execute(Node node);
}

/// A command that a [Node] connect to [peer].
class ConnectCommand implements NodeCommand {
  final Peer peer;

  ConnectCommand(this.peer);

  @override
  Future execute(Node node) async {
    await node.connect(peer);
  }
}

/// A command that a [Node] disconnect from [peer].
class DisconnectCommand implements NodeCommand {
  final Peer peer;

  DisconnectCommand(this.peer);

  @override
  Future execute(Node node) async {
    node.disconnect(peer);
  }
}
