import 'package:distributed/src/http_server_builder/request_handler.dart';
import 'package:distributed.http/vm.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('$RequestMatcher', () {
    test('should match a post request with the correct pattern', () {
      var matchedRequest = new MockServerHttpRequest();
      var badPathRequest = new MockServerHttpRequest();
      var badMethodRequest = new MockServerHttpRequest();

      when(matchedRequest.method).thenReturn('POST');
      when(matchedRequest.uri).thenReturn(new MockUri('/a'));
      when(badPathRequest.method).thenReturn('POST');
      when(badPathRequest.uri).thenReturn(new MockUri('/b'));
      when(badMethodRequest.method).thenReturn('GET');
      when(badMethodRequest.uri).thenReturn(new MockUri('/a'));

      var matcher = new RequestMatcher(r'/a');
      expect(matcher.matches(matchedRequest), isTrue);
      expect(matcher.matches(badPathRequest), isFalse);
      expect(matcher.matches(badMethodRequest), isFalse);
    });
  });
}

class MockServerHttpRequest extends Mock implements ServerHttpRequest {}

class MockUri extends Mock implements Uri {
  @override
  final String path;

  MockUri(this.path);
}
