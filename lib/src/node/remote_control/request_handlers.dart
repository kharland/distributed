import 'package:distributed/distributed.dart';
import 'package:distributed/src/http_server_builder/request_handler.dart';
import 'package:distributed/src/node/remote_control/node_command.dart';
import 'package:distributed.http/vm.dart';

HandlerCallback createConnectHandler(Sink<NodeCommand> commandSink) =>
    (ServerHttpRequest request, Map<String, String> args) async {
      commandSink
          .add(new ConnectCommand(Peer.deserialize(await request.first)));
    };

HandlerCallback createDisconnectHandler(Sink<NodeCommand> commandSink) =>
    (ServerHttpRequest request, Map<String, String> args) async {
      commandSink
          .add(new DisconnectCommand(Peer.deserialize(await request.first)));
    };
