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
    MockRequestMatcher mockMatcher;

    setUp(() {
      mockRequest = new MockServerHttpRequest();
      commandSink = new StreamController<NodeCommand>();
      mockMatcher = new MockRequestMatcher();
      when(mockMatcher.matches(any)).thenReturn(true);
    });

    test('$ConnectHandler should produce a $ConnectCommand', () {
      var mockConnectHandler = new ConnectHandler(mockMatcher, commandSink);
      when(mockRequest.first)
          .thenReturn(new Future.value(testPeer.serialize()));

      commandSink.stream.listen(expectAsync1((NodeCommand cmd) {
        expect(cmd, new isInstanceOf<ConnectCommand>());
        expect((cmd as ConnectCommand).peer, testPeer);
      }));

      mockConnectHandler.handle(mockRequest);
    });

    test('$DisconnectHandler should produce a $DisconnectCommand', () {
      var mockConnectHandler = new DisconnectHandler(mockMatcher, commandSink);
      when(mockRequest.first)
          .thenReturn(new Future.value(testPeer.serialize()));

      commandSink.stream.listen(expectAsync1((NodeCommand cmd) {
        expect(cmd, new isInstanceOf<DisconnectCommand>());
        expect((cmd as DisconnectCommand).peer, testPeer);
      }));

      mockConnectHandler.handle(mockRequest);
    });
  });
}

class MockServerHttpRequest extends Mock implements ServerHttpRequest {}

class MockRequestHandler extends Mock implements RequestHandler {}

class MockRequestMatcher extends Mock implements RequestMatcher {}
