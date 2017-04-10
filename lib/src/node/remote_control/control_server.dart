import 'dart:async';

import 'package:distributed/src/http_server_builder/http_server_builder.dart';
import 'package:distributed/src/node/remote_control/node_command.dart';
import 'package:distributed/src/node/remote_control/request_handlers.dart';
import 'package:distributed.http/vm.dart';

class ControlServer {
  final HttpServer _server;
  final StreamController<NodeCommand> _commandsController;

  ControlServer(this._server, this._commandsController);

  static Future<ControlServer> bind(String address, int port) async {
    var commandSink = new StreamController<NodeCommand>();
    return new ControlServer(
        await (new HttpServerBuilder()
              ..add(new ConnectHandler(connectMatcher, commandSink))
              ..add(new DisconnectHandler(disconnectMatcher, commandSink)))
            .bind(address, port),
        commandSink);
  }

  Stream<NodeCommand> get commands => _commandsController.stream;

  void close() {
    _server.close();
  }
}
