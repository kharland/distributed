import 'package:distributed/src/http_server/http_server.dart';
import 'package:distributed/src/http_server/request_handler.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('$HttpServerBuilder', () {
    test('Should create a $RequestHandler linked-list', () {
      var fooHandler = new MockRequestHandler();
      var barHandler = new MockRequestHandler();
      var bazHandler = new MockRequestHandler();

      new HttpServerBuilder()
        ..addHandler(fooHandler)
        ..addHandler(barHandler)
        ..addHandler(bazHandler);

      verify(fooHandler.successor = barHandler);
      verify(barHandler.successor = bazHandler);
      verifyNever(bazHandler.successor = any);
    });
  });
}

class MockRequestHandler extends Mock implements RequestHandler {}
