import 'package:distributed.http/environment/vm_testing.dart';
import 'package:distributed.http/src/testing/local_address.dart';
import 'package:distributed.http/vm.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:test/test.dart';

void main() {
  group('$TestHttpProvider', () {
    TestHttpProvider provider;

    setUp(() async {
      provider = new TestHttpProvider(new Logger('http'), 'localhost');
    });

    test('post should support sending a POST request', () async {
      var server = await provider.bindHttpServer('localhost', 1);
      server.take(1).first.then(expectAsync1((ServerHttpRequest req) async {
        expect(await req.first, 'hello');
        req.response.add('hi there!');
      }));
      var httpRequest =
          await provider.post('http://localhost:1', payload: 'hello');
      expect(httpRequest, emits('hi there!'));
    });

    test('should connect a socket.dart to a listener', () async {
      var socketServer = await provider.bindSocketServer('localhost', 1);
      var connectorSocket;
      socketServer.take(1).first.then(expectAsync1((Socket listenerSocket) {
        expect(listenerSocket.port, 1);
        expect(connectorSocket.port, greaterThan(1));
        expect(listenerSocket, emits('Hi!'));
        connectorSocket.add('Hi!');
      }));
      connectorSocket = await provider.connectSocket('ws://localhost:1');
    });

    group('bindSocketServer should return a server that', () {
      test('frees its address when closed', () async {
        var socketServer = await provider.bindSocketServer('localhost', 1);
        provider
            .bindSocketServer('localhost', 1)
            .catchError(expectAsync1((e) async {
          expect(e, new isInstanceOf<SocketException>());
          socketServer.close();
          await provider.bindSocketServer('localhost', 1);
        }));
      });

      test(
          'frees its address when closed and all resonders/responses are '
          'closed',
          () {});
    });
  });
}
