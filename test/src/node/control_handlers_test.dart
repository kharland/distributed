import 'dart:async';
import 'dart:io';

import 'package:distributed/src/http_server/request_handler.dart';
import 'package:distributed/src/node/node.dart';
import 'package:distributed/src/node/remote_interaction_server/request_handlers/control_handlers.dart';
import 'package:distributed/src/objects/interfaces.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('$ConnectHandler', () {
    ConnectHandler connectHandler;
    MockNode node;
    MockHttpRequest request;
    MockRequestMatcher matcher;

    void commonSetUp({String uriPath: '', String method: ''}) {
      node = new MockNode();
      request = new MockHttpRequest();
      matcher = new MockRequestMatcher();
      connectHandler = new ConnectHandler(node, matcher);
    }

    test("should forward requests that it doesn't match on", () async {
      commonSetUp();
      var successor = new MockRequestHandler();

      connectHandler.successor = successor;
      when(matcher.matches(request)).thenReturn(false);

      await connectHandler.handle(request);
      verify(successor.handle(request));
      verifyZeroInteractions(request);
    });

    test('connect a node to a peer if it matches the request', () async {
      commonSetUp();
      final peer = new Peer('test', HostMachine.Null);

      when(matcher.matches(request)).thenReturn(true);
      when(request.transform(any))
          .thenReturn(new Future.value(serialize(peer)).asStream());
      when(node.connect(peer)).thenReturn(new Future.value(true));

      await connectHandler.handle(request);
      verify(node.connect(peer));
    });

    // TODO: Test bad data in HttpRequest.
  });
}

class MockNode extends Mock implements Node {}

class MockHttpRequest extends Mock implements HttpRequest {}

class MockRequestHandler extends Mock implements RequestHandler {}

class MockRequestMatcher extends Mock implements RequestMatcher {}
