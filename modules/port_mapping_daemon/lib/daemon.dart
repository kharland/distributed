import 'dart:async';
import 'dart:io';

import 'package:distributed.node/src/networking/channel_server.dart';
import 'package:distributed.node/src/networking/message_channel.dart';
import 'package:distributed.port_mapping_daemon/src/api/api.dart';
import 'package:distributed.port_mapping_daemon/src/database/lib/database.dart';
import 'package:distributed.port_mapping_daemon/src/executors/daemon_executors.dart';
import 'package:distributed.port_mapping_daemon/src/executors/executor.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:distributed.port_mapping_daemon/src/daemon_handle.dart';

/// The distributed_dart port mapping daemon
class PortMappingDaemon {
  static const defaultHost = 'localhost';
  static const defaultPort = 4369;
  static const defaultCookie = 'cookie';
  static final defaultDatabaseFile = new File('.daemon.db');

  final StreamController<MessageChannel> _onChannel =
      new StreamController<MessageChannel>.broadcast();
  final DaemonHandle _handle;
  final Database<String, int> _database;

  ChannelServer _channelServer;

  PortMappingDaemon(this._handle, {Database<String, int> nodeDatabase})
      : _database = nodeDatabase ??
            new MemoryDatabase<String, int>(defaultDatabaseFile);

  /// The url for connecting to this daemon.
  String get url => _handle.url;

  /// The set of names of all nodes registered with this daemon.
  Set<String> get nodes => _database.keys;

  /// Makes this daemon listening for requests.
  Future<Null> start() async {
    _channelServer = new ChannelServer(_handle.hostname, _handle.port)
      ..onSocket.listen(_handleConnection);
    await _channelServer.onStartup;
  }

  /// Stops the daemon from listening for requests.
  void stop() {
    _channelServer.stop();
    _onChannel.close();
  }

  /// Returns the port for the node named [nodeName].
  ///
  /// If no node is found, returns -1.
  int getPort(String nodeName) => _database.get(nodeName) ?? -1;

  /// Returns the next available unused port.
  Future<int> _getUnusedPort() =>
      ServerSocket.bind('localhost', 0).then((socket) {
        var port = socket.port;
        socket.close();
        return port;
      });

  void _handleConnection(WebSocket rawSocket) {
    var socket = new DaemonSocket(rawSocket);
    Executor executor;
    StreamSubscription<String> initiationSubscription;

    initiationSubscription = socket.stream.listen((String payload) {
      initiationSubscription.cancel();

      if (!Entity.canParseAs(RequestInitiation, payload)) {
        socket.sendHandshakeFailed('Invalid message');
        return;
      }

      var request = new RequestInitiation.fromString(payload);
      if (request.cookie != _handle.cookie) {
        socket.sendHandshakeFailed('Invalid cookie');
        return;
      }

      switch (request.type) {
        case RequestType.ping:
          executor = new PingExecutor();
          break;
        case RequestType.register:
          executor = new RegisterNodeExecutor(_database, _getUnusedPort);
          break;
        case RequestType.deregister:
        case RequestType.connect:
        case RequestType.list:
          throw new UnimplementedError();
        default:
          throw new UnimplementedError(request.type.toString());
      }

      executor.done.then((result) {
        if (result.isError) {
          print('Request failed: ${result.message}');
          socket.close(status.policyViolation);
        } else {
          print('Request succeeded: ${result.message}');
        }
      });

      executor.execute(socket);
    });
  }
}
