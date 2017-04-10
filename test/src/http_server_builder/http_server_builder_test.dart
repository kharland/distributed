import 'package:distributed/src/http_server_builder/http_server_builder.dart';
import 'package:distributed/src/http_server_builder/request_handler.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('$HttpServerBuilder', () {
    test('Should create a $RequestHandler linked-list', () {
      var fooHandler = new MockRequestHandler();
      var barHandler = new MockRequestHandler();
      var bazHandler = new MockRequestHandler();

      new HttpServerBuilder()
        ..add(fooHandler)
        ..add(barHandler)
        ..add(bazHandler);

      verify(fooHandler.successor = barHandler);
      verify(barHandler.successor = bazHandler);
      verifyNever(bazHandler.successor = any);
    });
  });
}

class MockRequestHandler extends Mock implements RequestHandler {}
