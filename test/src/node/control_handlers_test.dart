import 'dart:async';
import 'dart:io';

import 'package:distributed/src/http_server/request_handler.dart';
import 'package:distributed/src/node/control_server/request_handlers.dart';
import 'package:distributed/src/node/node.dart';
import 'package:distributed.objects/public.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('$ConnectHandler', () {
    ConnectHandler connectHandler;
    MockNode node;
    MockHttpRequest request;
    MockRequestMatcher matcher;

    setUp(() {
      node = new MockNode();
      request = new MockHttpRequest();
      when(request.response).thenReturn(new MockHttpResponse());
      matcher = new MockRequestMatcher();
      connectHandler = new ConnectHandler(node, matcher);
    });

    test("should forward requests that it doesn't match", () async {
      var successor = new MockRequestHandler();

      connectHandler.successor = successor;
      when(matcher.matches(request)).thenReturn(false);

      await connectHandler.handle(request);
      verify(successor.handle(request));
      verifyZeroInteractions(request);
    });

    test('connect a node to a peer if it matches the request', () async {
      final peer = new Peer('test', HostMachine.Null);

      when(matcher.matches(request)).thenReturn(true);
      when(request.transform(any))
          .thenReturn(new Future.value(Peer.serialize(peer)).asStream());
      when(node.connect(peer)).thenReturn(new Future.value(true));

      await connectHandler.handle(request);
      verify(node.connect(peer));
    });

    // TODO: Test bad data in HttpRequest.
  });

  group('$PingHandler', () {
    PingHandler pingHandler;
    MockHttpRequest request;
    MockHttpResponse response;
    MockRequestMatcher matcher;

    setUp(() {
      request = new MockHttpRequest();
      response = new MockHttpResponse();
      when(request.response).thenReturn(response);
      matcher = new MockRequestMatcher();
      pingHandler = new PingHandler(matcher);
    });

    test("should forward requests that it doesn't match ", () async {
      var successor = new MockRequestHandler();

      pingHandler.successor = successor;
      when(matcher.matches(request)).thenReturn(false);

      await pingHandler.handle(request);
      verify(successor.handle(request));
      verifyZeroInteractions(request);
    });

    test('respond to a ping if it matches the request', () async {
      when(matcher.matches(request)).thenReturn(true);
      await pingHandler.handle(request);
      verify(response.statusCode = HttpStatus.OK);
      verify(response.close());
    });
  });
}

class MockNode extends Mock implements Node {}

class MockHttpRequest extends Mock implements HttpRequest {}

class MockHttpResponse extends Mock implements HttpResponse {}

class MockRequestHandler extends Mock implements RequestHandler {}

class MockRequestMatcher extends Mock implements RequestMatcher {}
