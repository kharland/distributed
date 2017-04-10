import 'dart:async';

import 'package:distributed/src/port_daemon/client.dart';
import 'package:distributed/src/port_daemon/port_daemon_routes.dart';
import 'package:distributed.http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('Port daemon client api', () {
    const daemonHost = 'localhost';
    const daemonPort = 1;
    const daemonUrl = 'http://$daemonHost:$daemonPort';
    final timeoutPlus100ms =
        HttpWithTimeout.TIMEOUT_DURATION + const Duration(milliseconds: 100);

    HttpWithTimeout http;
    MockHttp mockHttp;
    DaemonRoutes routes;

    Future<HttpResponse> createResponseFuture(Iterable<String> values) =>
        new Future.value(new FakeHttpResponse(new Stream.fromIterable(values)));

    setUp(() async {
      mockHttp = new MockHttp();
      http = new HttpWithTimeout(mockHttp);
      routes = new DaemonRoutes(daemonUrl);
      // Always enable ping response.
      when(mockHttp.get(routes.ping())).thenReturn(new Future.value(''));
    });

    group('pingDaemon', () {
      test('should return true if the daemon returns a response', () async {
        when(mockHttp.get(routes.ping())).thenReturn(new Future.value(''));
        expect(await pingDaemon(http, routes), isTrue);
      });

      test("should return false if the daemon doesn't return a response",
          () async {
        when(mockHttp.get(routes.ping()))
            .thenReturn(new Future.delayed(timeoutPlus100ms));
        expect(pingDaemon(http, routes), completion(isFalse));
      });
    });

    group('getNodeConnectionUrl', () {
      test("should return the node's url if the daemon returns a response",
          () async {
        when(mockHttp.get(routes.node('a')))
            .thenReturn(createResponseFuture(['123']));
        expect(getNodeConnectionUrl(http, routes, 'a'),
            completion('ws://localhost:123'));
      });

      test(
          "should return the empty string if the daemon doesn't return a response",
          () async {
        when(mockHttp.get(routes.node('a')))
            .thenReturn(new Future.delayed(timeoutPlus100ms));
        expect(getNodeConnectionUrl(http, routes, 'a'), completion(isEmpty));
      });
    });

    group('getNodeControlUrl', () {
      test("should return the node's url if the daemon returns a response",
          () async {
        when(mockHttp.get(routes.controlServer('a')))
            .thenReturn(createResponseFuture(['123']));
        expect(getNodeControlUrl(http, routes, 'a'),
            completion('http://localhost:123'));
      });

      test(
          "should return the empty string if the daemon doesn't return a response",
          () async {
        when(mockHttp.get(routes.controlServer('a')))
            .thenReturn(new Future.delayed(timeoutPlus100ms));
        expect(getNodeControlUrl(http, routes, 'a'), completion(isEmpty));
      });
    });

    group('getNodeDiagnosticsUrl', () {
      test("should return the node's url if the daemon returns a response",
          () async {
        when(mockHttp.get(routes.diagnosticsServer('a')))
            .thenReturn(createResponseFuture(['123']));
        expect(getNodeDiagnosticsUrl(http, routes, 'a'),
            completion('http://localhost:123'));
      });

      test(
          "should return the empty string if the daemon doesn't return a response",
          () async {
        when(mockHttp.get(routes.diagnosticsServer('a')))
            .thenReturn(new Future.delayed(timeoutPlus100ms));
        expect(getNodeDiagnosticsUrl(http, routes, 'a'), completion(isEmpty));
      });
    });
  });

//  group('$PortDaemon', () {
//    setUp(() => commonSetUp());
//
//    tearDown(() => commonTearDown());
//
//    test('should register a node', () async {
//      expect(await clientA.registerNode(), greaterThan(0));
//      expect(await daemon.getPort('A'), greaterThan(0));
//    });
//
//    test('nodes should return the nodes registered with the daemon', () async {
//      expect(daemon.nodes, isEmpty);
//      await clientA.registerNode();
//      await clientB.registerNode();
//      expect(daemon.nodes, ['A', 'B']);
//    });
//
//    test('should fail to register a currently registered node', () async {
//      expect(await clientA.registerNode(), greaterThan(0));
//      expect(await clientA.registerNode(), Ports.error);
//    });
//
//    test('should be able to deregister a node', () async {
//      expect(await clientA.registerNode(), greaterThan(0));
//      expect(await daemon.getPort('A'), greaterThan(0));
//      expect(await clientA.deregister(), true);
//      expect(await daemon.getPort('A'), Ports.error);
//    });
//
//    test('should exchange the list of nodes registered on the server',
//        () async {
//      expect(await clientA.getNodes(), isEmpty);
//      expect(await clientA.registerNode(), greaterThan(0));
//      expect(await clientB.registerNode(), greaterThan(0));
//      expect((await clientA.getNodes()).keys, unorderedEquals(['A', 'B']));
//    });
//
//    test("should exchange a node's information", () async {
//      expect(await clientA.lookup('A'), '');
//      var port = await clientA.registerNode();
//      expect(port, greaterThan(0));
//      expect(await daemon.getPort('A'), port);
//      expect(await clientA.lookup('A'), 'ws://localhost:$port');
//    });
//  });
}

class MockHttp extends Mock implements Http {}

class FakeHttpResponse extends StreamView<String> implements HttpResponse {
  FakeHttpResponse(Stream<String> stream) : super(stream);
}
