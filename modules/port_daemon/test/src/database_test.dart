@TestOn('vm')
import 'dart:async';

import 'package:distributed.port_daemon/src/database/database.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

/// Common tests for [Database].
void testDatabase({
  @required FutureOr<Database<String, String>> setup(),
  @required FutureOr<Null> teardown(),
}) {
  Database<String, String> database;

  group('', () {
    setUp(() async {
      // ignore: await_only_futures
      database = await setup();
    });

    tearDown(() => teardown());

    test(
        'containsKey should return true if the database contains an entry for '
        'the given key', () async {
      await database.insert('A', 'B');
      await database.insert('C', 'D');
      expect(database.containsKey('A'), isTrue);
      expect(database.containsKey('C'), isTrue);
      expect(database.containsKey('B'), isFalse);
    });

    test('insert should insert a value for some key', () async {
      await database.insert('A', 'B');
      expect(await database.get('A'), 'B');
    });

    test('update should update a value for some key', () async {
      await database.insert('A', 'B');
      await database.update('A', 'C');
      expect(await database.get('A'), 'C');
    });

    test('get should return the value associated with a key', () async {
      await database.insert('A', 'B');
      expect(await database.get('A'), 'B');
      expect(await database.get('B'), isNull);
    });

    test('remove should remove the value associated with a key', () async {
      await database.insert('A', 'B');
      await database.remove('A');
      expect(await database.get('A'), isNull);
    });

    test('where should return all items that pass the filter', () async {
      await database.insert('A', 'aa');
      await database.insert('B', 'bb');
      await database.insert('C', 'c');
      expect(await database.where((_, String value) => value.length > 1),
          unorderedEquals(['aa', 'bb']));
    });
  });
}
