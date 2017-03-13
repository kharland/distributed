import 'dart:io';
import 'package:distributed.monitoring/file_system.dart';
import 'package:quiver/time.dart';
import 'package:test/test.dart';

void main() {
  group('$FileSystem', () {
    final clock = new Clock(() => new DateTime(2017));
    FileSystem fileSystem;

    setUp(() {
      fileSystem = new FileSystem('', clock);
    });

    test("homeDirectory should return the path to the user's home directory",
        () {
      final env = <String, String>{
        'HOME': 'a',
        'USERPROFILE': 'b',
      };
      expect(FileSystem.homeDirectory(OperatingSystem.linux, env), 'a');
      expect(FileSystem.homeDirectory(OperatingSystem.macOS, env), 'a');
      expect(FileSystem.homeDirectory(OperatingSystem.windows, env), 'b');
    });

    test('root should return the rood path', () {
      expect(new FileSystem('a', clock).root, 'a');
      expect(new FileSystem('b', clock).root, 'b');
    });

    test("getNodeLog should return a node's log file", () {
      expect(fileSystem.getNodeLog('a').path,
          new File('/logs/a.${clock.now()}.log').path);
    });

    test("getDaemonLog should return the daemon log file", () {
      expect(fileSystem.getDaemonLog().path,
          new File('/logs/port_daemon.${clock.now()}.log').path);
    });
  });
}
