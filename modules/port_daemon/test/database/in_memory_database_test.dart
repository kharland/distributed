@TestOn("vm")
import 'dart:async';
import 'dart:io';

import 'package:distributed.port_daemon/src/database/database.dart';
import 'package:distributed.port_daemon/src/database/serializer.dart';
import 'package:test/test.dart';

import 'src/database_test.dart';

void main() {
  group('$MemoryDatabase', () {
    MemoryDatabase<String, String> database;
    File testFile;

    Future<Database<String, String>> setup() async {
      testFile = new File('.test.db');
      if (testFile.existsSync()) {
        testFile.deleteSync();
      }
      testFile.createSync();

      return new MemoryDatabase<String, String>(testFile,
          recordSerializer: new RecordSerializer<String, String>(
              new StringSerializer(), new StringSerializer()));
    }

    Future teardown() async {
      testFile.deleteSync();
    }

    testDatabase(setup, teardown);

    test('saveOnDisk should write all contents to disk', () async {
      database = await setup();

      await database.insert('A', 'B');
      await database.insert('C', 'D');
      database.save();
      var contents = testFile.readAsStringSync();
      expect(contents, contains('A'));
      expect(contents, contains('B'));
      expect(contents, contains('C'));
      expect(contents, contains('D'));

      teardown();
    });
  });
}
