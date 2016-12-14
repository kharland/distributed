import 'dart:async';
import 'dart:io';

import 'package:distributed/src/networking/channel_server.dart';
import 'package:distributed/src/networking/message_channel.dart';
import 'package:distributed/src/port_mapping_daemon/api/api.dart';
import 'package:distributed/src/port_mapping_daemon/handshake/handshake.dart';
import 'package:web_socket_channel/status.dart' as status;

// TODO: Save port-mappings so server can be restarted without killing nodes.
// TODO: handle case when there is no port available for a new node.

/// The distributed_dart port mapping daemon
class PortMappingDaemon {
  static const defaultHost = 'localhost';
  static const defaultPort = 4369;
  static const defaultCookie = 'cookie';

  final Map<String, int> _nodeRegistry = <String, int>{};
  final StreamController<MessageChannel> _onChannel =
      new StreamController<MessageChannel>.broadcast();
  final String hostname;
  final int port;
  final String cookie;
  ChannelServer _channelServer;

  PortMappingDaemon(
      {this.cookie: defaultCookie,
      this.hostname: defaultHost,
      this.port: defaultPort});

  /// Starts the daemon listening for connections.
  Future<Null> start() async {
    _channelServer = new ChannelServer(hostname, port)
      ..onSocket.listen(_handshake);
    await _channelServer.onStartup;
  }

  /// Stops the daemon from accepting connections.
  void stop() {
    _channelServer.stop();
    _onChannel.close();
  }

  String get url => 'ws://$hostname:$port';

  /// Returns a Set of the names of all nodes registered in this
  /// [PortMappingDaemon].
  Set<String> get nodes => _nodeRegistry.keys.toSet();

  /// Registers the node with name [name] to this [PortMappingDaemon].
  ///
  /// Returns true iff registration succeeded.
  ///
  /// No other node named [name] may register itself with this daemon while some
  /// node is registered under the same [name].
  Future<bool> registerNode(String name) async {
    if (getPort(name) > 0) {
      return false;
    }
    _nodeRegistry[name] = await _getUnusedPort();
    return true;
  }

  /// Deregisters the node with name [name] from this [PortMappingDaemon].
  ///
  /// Returns true iff the node with [name] was deregistered.
  bool deregisterNode(String name) => _nodeRegistry.remove(name) != null;

  /// Returns the port for the node named [nodeName].
  ///
  /// If no node is found, returns -1.
  int getPort(String nodeName) =>
      _nodeRegistry.containsKey(nodeName) ? _nodeRegistry[nodeName] : -1;

  /// Returns the next available unused port.
  Future<int> _getUnusedPort() =>
      ServerSocket.bind('localhost', 0).then((socket) {
        var port = socket.port;
        socket.close();
        return port;
      });

  void _handshake(WebSocket rawSocket) {
    var socket = new DaemonSocket(rawSocket);
    var handshake = receiveHandshake(this)..start(socket);

    handshake.done.then((result) {
      if (result.isError) {
        print('Handshake failed: ${result.message}');
        socket.close(status.policyViolation);
      } else {
        print(result.message);
      }
    });
  }
}
