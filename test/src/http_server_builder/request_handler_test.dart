import 'dart:async';

import 'package:distributed/src/http_server_builder/request_handler.dart';
import 'package:distributed/src/http_server_builder/request_template.dart';
import 'package:distributed.http/vm.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('$RequestHandler', () {
    [
      {
        'method': 'GET',
        'constructor': (RequestTemplate t, HandlerCallback c) =>
            new RequestHandler.get(t, c)
      },
      {
        'method': 'POST',
        'constructor': (RequestTemplate t, HandlerCallback c) =>
            new RequestHandler.post(t, c)
      },
      {
        'method': 'DELETE',
        'constructor': (RequestTemplate t, HandlerCallback c) =>
            new RequestHandler.delete(t, c)
      }
    ].forEach((Map testCase) {
      var method = testCase['method'];
      var createHandler = testCase['constructor'];

      group(method, () {
        const fooTemplate = const RequestTemplate('/foo/:bar');
        RequestHandler getHandler;
        TestRequestCallback testCallback;

        setUp(() async {
          testCallback = new TestRequestCallback();
          getHandler = createHandler(fooTemplate, testCallback.call);
        });

        test('should invoke its callback if a request matches', () async {
          const path = '/foo/shoo';
          var mockTemplate = new MockRequestTemplate();
          var mockRequest = new MockHttpRequest();

          when(mockRequest.uri).thenReturn(Uri.parse(path));
          when(mockRequest.method).thenReturn(method);
          when(mockTemplate.matches(path)).thenReturn(true);

          await getHandler.handle(mockRequest);
          expect(testCallback.callCount, 1, reason: method);
        });
      });
    });
  });
}

/// A object for capturing [HandlerCallback] invocations.
class TestRequestCallback {
  /// The number of times [call] has been called.
  int callCount = 0;

  /// Passed as the callback to a [RequestHandler].
  Future call(ServerHttpRequest _, Map<String, String> __) async {
    callCount++;
  }
}

class MockHttpRequest extends Mock implements ServerHttpRequest {}

class MockRequestTemplate extends Mock implements RequestTemplate {}
