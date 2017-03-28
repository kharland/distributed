import 'dart:async';
import 'dart:io';

import 'package:distributed/src/http_server/route.dart';
import 'package:distributed/src/http_server/router.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('$Router', () {
    group('route', () {
      MockHttpRequest request;

      setUp(() async {
        request = new MockHttpRequest();
      });

      /// Mocks all methods on [route] to return true values.
      void mockReturnTrueForAll(MockRoute route) {
        when(route.accepts(request)).thenReturn(true);
        when(route.sendToHandler(request)).thenReturn(new Future.value(true));
      }

      test('should keeping routing while each handler returns true', () async {
        final routes = <MockRoute>[new MockRoute(), new MockRoute()];
        routes.forEach(mockReturnTrueForAll);
        final router = new Router.fromRoutes(routes);
        await router.route(request);
        routes.forEach((route) {
          verify(route.sendToHandler(request));
        });
      });

      test('should only route to routes that accept a request', () async {
        final accepts1 = new MockRoute();
        final accepts2 = new MockRoute();
        final rejects = new MockRoute();
        final router = new Router.fromRoutes([accepts1, rejects, accepts2]);

        mockReturnTrueForAll(accepts1);
        mockReturnTrueForAll(accepts2);
        when(rejects.accepts(request)).thenReturn(false);
        await router.route(request);
        verifyInOrder([
          verify(accepts1.accepts(request)),
          verify(rejects.accepts(request)),
          verify(accepts2.accepts(request)),
          verify(accepts1.sendToHandler(request)),
          verify(accepts2.sendToHandler(request)),
          verifyNever(rejects.sendToHandler(request)),
        ]);
      });
    });
  });
}

class MockHttpRequest extends Mock implements HttpRequest {}

class MockRoute extends Mock implements Route {}
