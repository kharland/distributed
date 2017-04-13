import 'package:distributed/src/http_server_builder/request_template.dart';
import 'package:test/test.dart';

void main() {
  group('$RequestTemplate', () {
    const rootTemplate = const RequestTemplate('/');
    const fooTemplate = const RequestTemplate('/foo/:bar');

    const badFormatTemplates = const <String>[
      '/123',
      '\\foo/bar',
      '/FOO/bar',
      'foo/bar'
    ];

    group('computeArgPositions', () {
      // convenience var.
      final computePositions = RequestTemplate.computeArgPositions;
      test('should return the empty list for an incorrectly formatted request',
          () {
        badFormatTemplates.forEach((template) {
          expect(computePositions(template), isEmpty, reason: template);
        });
      });

      test('should return the empty list for a template with no args', () {
        expect(computePositions(''), isEmpty);
        expect(computePositions('/'), isEmpty);
        expect(computePositions('/foo'), isEmpty);
        expect(computePositions('/foo/bar'), isEmpty);
      });

      test('should return the correct indices for a template', () {
        expect(computePositions('/:foo'), orderedEquals([0]));
        expect(computePositions('/:foo/bar'), orderedEquals([0]));
        expect(computePositions('/foo/:bar'), orderedEquals([1]));
        expect(computePositions('/foo/:bar/baz'), orderedEquals([1]));
        expect(computePositions('/foo/:bar/:baz'), orderedEquals([1, 2]));
        expect(computePositions('/:foo/bar/:baz'), orderedEquals([0, 2]));
      });
    });

    group('matches', () {
      test('should return true if a given request matches', () {
        expect(rootTemplate.matches(''), isFalse);
        expect(rootTemplate.matches('/'), isTrue);
        expect(rootTemplate.matches('/foo'), isTrue);

        expect(fooTemplate.matches(''), isFalse);
        expect(fooTemplate.matches('/'), isFalse);
        expect(fooTemplate.matches('/foo'), isFalse);
        expect(fooTemplate.matches('/foo/bar'), isTrue);
        expect(fooTemplate.matches('/foo/roo'), isTrue);
        expect(fooTemplate.matches('/foo/roo/baz'), isTrue);
      });

      test('should return false for an incorrectly formatted request', () {
        badFormatTemplates.forEach((template) {
          expect(fooTemplate.matches(template), isFalse, reason: template);
        });
      });
    });

    group('parseArguments', () {
      const multiArgTemplate = const RequestTemplate('/baz/:bang/boom/:bow');

      test('should return the empty map for an incorrectly formatted request',
          () {
        badFormatTemplates.forEach((template) {
          expect(fooTemplate.parseArguments(template), isEmpty,
              reason: template);
        });
      });

      test("should return the empty map for a request that doens't match", () {
        expect(multiArgTemplate.parseArguments('/baz/arg/wrongpath/another'),
            isEmpty);
        expect(multiArgTemplate.parseArguments('/'), isEmpty);
        expect(multiArgTemplate.parseArguments(''), isEmpty);
        expect(multiArgTemplate.parseArguments('/baz/bang'), isEmpty);
      });

      test('should return the empty map if the template has no arguments', () {
        const noArgTemplate = const RequestTemplate('/baz/bang');
        expect(noArgTemplate.parseArguments('/baz/bang'), isEmpty);
        expect(noArgTemplate.parseArguments('/baz/bang/boom'), isEmpty);
      });

      test('should return the arguments specified in a request', () {
        expect(fooTemplate.parseArguments('/foo/bar'), {'bar': 'bar'});
        expect(fooTemplate.parseArguments('/foo/baz/bang'), {'bar': 'baz'});
        expect(
            fooTemplate.parseArguments('/foo/bees/baz/bang'), {'bar': 'bees'});

        expect(multiArgTemplate.parseArguments('/baz/bart/boom/bang'),
            {'bang': 'bart', 'bow': 'bang'});
      });
    });
  });
}
