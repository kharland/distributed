import 'dart:async';
import 'package:distributed.objects/objects.internal.dart';
import 'package:distributed/src/http_server_builder/request_handler.dart';
import 'package:distributed/src/node/remote_control/control_server.dart';
import 'package:distributed/src/node/remote_control/node_command.dart';
import 'package:distributed/src/node/remote_control/request_handlers.dart';
import 'package:distributed.http/vm.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('$ControlServer request handlers', () {
    final testPeer = new Peer('test', HostMachine.localHost);
    StreamController<NodeCommand> commandSink;
    MockServerHttpRequest mockRequest;

    setUp(() {
      mockRequest = new MockServerHttpRequest();
      commandSink = new StreamController<NodeCommand>();
    });

    test('connectHandler should produce a $ConnectCommand', () {
      var mockConnectHandler = createConnectHandler(commandSink);
      when(mockRequest.first)
          .thenReturn(new Future.value(testPeer.serialize()));

      commandSink.stream.listen(expectAsync1((NodeCommand cmd) {
        expect(cmd, new isInstanceOf<ConnectCommand>());
        expect((cmd as ConnectCommand).peer, testPeer);
      }));

      mockConnectHandler(mockRequest, {});
    });

    test('disconnectHandler should produce a $DisconnectCommand', () {
      var mockConnectHandler = createDisconnectHandler(commandSink);
      when(mockRequest.first)
          .thenReturn(new Future.value(testPeer.serialize()));

      commandSink.stream.listen(expectAsync1((NodeCommand cmd) {
        expect(cmd, new isInstanceOf<DisconnectCommand>());
        expect((cmd as DisconnectCommand).peer, testPeer);
      }));

      mockConnectHandler(mockRequest, {});
    });
  });
}

class MockServerHttpRequest extends Mock implements ServerHttpRequest {}

class MockRequestHandler extends Mock implements RequestHandler {}
