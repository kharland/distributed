import 'dart:async';
import 'dart:io';

import 'package:distributed.port_mapping_daemon/daemon.dart';
import 'package:distributed.port_mapping_daemon/src/http_client.dart';
import 'package:distributed.port_mapping_daemon/src/http_server.dart';
import 'package:seltzer/platform/vm.dart';
import 'package:test/test.dart';

void main() {
  useSeltzerInVm();

  group('$DaemonClient and $DaemonServer', () {
    DaemonServer server;
    DaemonClient client;
    Daemon daemon;
    File dbFile;

    setUpAll(() async {
      dbFile = new File('.test.db');
      if (dbFile.existsSync()) {
        dbFile.deleteSync();
      }

      daemon = new Daemon(new NodeDatabase(dbFile));
      server = new DaemonServerBuilder().setDaemon(daemon).build();
      client = new DaemonClient(server.handle, new VmSeltzerHttp());
      server.start();
    });

    tearDownAll(() async {
      server.stop();
      dbFile.deleteSync();
    });

    tearDown(() => Future.wait(daemon.nodes.map(daemon.deregisterNode)));

    test('should be able to ping each other', () async {
      expect(await client.isDaemonRunning(), isTrue);
    });

    test('should register a node', () async {
      expect(await client.registerNode('A'), greaterThan(0));
      expect(await daemon.lookupPort('A'), greaterThan(0));
    });

    test('should fail to register a currently registered node', () async {
      expect(await client.registerNode('A'), greaterThan(0));
      expect(await client.registerNode('A'), -1);
    });

    test('should deregister a node', () async {
      expect(await client.registerNode('A'), greaterThan(0));
      expect(await daemon.lookupPort('A'), greaterThan(0));
      expect(await client.deregisterNode('A'), true);
      expect(await daemon.lookupPort('A'), -1);
    });

    test('should exchange the list of nodes registered on the server',
        () async {
      expect(await client.listNodes(), isEmpty);
      expect(await client.registerNode('A'), greaterThan(0));
      expect(await client.registerNode('B'), greaterThan(0));
      expect((await client.listNodes()).keys, unorderedEquals(['A', 'B']));
    });
  });
}
