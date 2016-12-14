import 'dart:async';
import 'dart:io';

import 'package:distributed.port_mapping_daemon/src/database/lib/database.dart';
import 'package:distributed.port_mapping_daemon/src/database/lib/serializer.dart';
import 'src/database_test.dart';

import 'package:test/test.dart';

void main() {
  group('$MemoryDatabase', () {
    MemoryDatabase<String, String> database;
    File testFile;

    Future<Database<String, String>> setup() async {
      testFile = new File('./test.db.txt');
      if (testFile.existsSync()) {
        testFile.deleteSync();
      }
      testFile.createSync();

      return new MemoryDatabase<String, String>(testFile,
          recordSerializer: new RecordSerializer(
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
      await database.save();
      var contents = testFile.readAsStringSync();
      expect(contents, contains('A'));
      expect(contents, contains('B'));
      expect(contents, contains('C'));
      expect(contents, contains('D'));

      teardown();
    });
  });
}