import 'dart:async';
import 'package:distributed.http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group("$HttpWithTimeout", () {
    const url = 'http://test.com';
    final timeoutPlus100ms =
        HttpWithTimeout.TIMEOUT_DURATION + const Duration(milliseconds: 100);
    MockHttp mockHttp;
    HttpWithTimeout http;

    setUp(() {
      mockHttp = new MockHttp();
      http = new HttpWithTimeout(mockHttp);
    });

    [
      ['get', (String url) => http.get(url)],
      ['post', (String url) => http.post(url)],
      ['delete', (String url) => http.delete(url)],
    ].forEach((testCase) {
      var description = testCase.first;
      var method = testCase.last;

      group(description, () {
        test('should timeout after ${HttpWithTimeout.TIMEOUT_DURATION} seconds',
            () {
          when(mockHttp.get(url))
              .thenReturn(new Future.delayed(timeoutPlus100ms));
          when(mockHttp.post(url, payload: null))
              .thenReturn(new Future.delayed(timeoutPlus100ms));
          when(mockHttp.delete(url))
              .thenReturn(new Future.delayed(timeoutPlus100ms));
          expect(method(url), throwsA(new isInstanceOf<TimeoutException>()));
        });

        test("shouldn't timeout if the response completes in time", () {
          when(mockHttp.get(url)).thenReturn(new Future.value(''));
          when(mockHttp.post(url, payload: null))
              .thenReturn(new Future.value(''));
          when(mockHttp.delete(url)).thenReturn(new Future.value(''));
          expect(method(url), completion(isEmpty));
        });
      });
    });
  });
}

class MockHttp extends Mock implements Http {}
