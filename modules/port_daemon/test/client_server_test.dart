import 'dart:async';
import 'dart:io';

import 'package:distributed.port_daemon/daemon.dart';
import 'package:distributed.port_daemon/src/http_client.dart';
import 'package:distributed.port_daemon/src/http_server.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:test/test.dart';
import 'package:seltzer/platform/vm.dart';

void main() {
  useSeltzerInVm();

  group('$DaemonServer', () {
    DaemonServer server;
    DaemonClient client;
    Daemon daemon;
    File dbFile;

    setUp(() async {
      dbFile = new File('.test.db');
      if (dbFile.existsSync()) {
        dbFile.deleteSync();
      }

      daemon = new Daemon(new NodeDatabase(dbFile));
      server = new DaemonServer(daemon, cookie: 'test');
      client = new DaemonClient(new VmSeltzerHttp(), cookie: server.cookie);
      await server.start();
    });

    tearDown(() {
      server.stop();
      dbFile.deleteSync();
      Future.wait(daemon.nodes.map(daemon.deregisterNode));
    });

    tearDownAll(() {
      dbFile.deleteSync();
    });

    test('should reject requests with a bad cookie', () async {
      var badClient =
          new DaemonClient(new VmSeltzerHttp(), cookie: 'bad${server.cookie}');
      expect(await badClient.registerNode('A'), lessThan(0));
    });

    test('should be able to ping each other', () async {
      expect(await client.isDaemonRunning(), isTrue);
    });

    test('should register a node', () async {
      expect(await client.registerNode('A'), greaterThan(0));
      expect(await daemon.lookupPort('A'), greaterThan(0));
    });

    test('should fail to register a currently registered node', () async {
      expect(await client.registerNode('A'), greaterThan(0));
      expect(await client.registerNode('A'), Ports.invalidPort);
    });

    test('should deregister a node', () async {
      expect(await client.registerNode('A'), greaterThan(0));
      expect(await daemon.lookupPort('A'), greaterThan(0));
      expect(await client.deregisterNode('A'), true);
      expect(await daemon.lookupPort('A'), Ports.invalidPort);
    });

    test('should exchange the list of nodes registered on the server',
        () async {
      expect(await client.listNodes(), isEmpty);
      expect(await client.registerNode('A'), greaterThan(0));
      expect(await client.registerNode('B'), greaterThan(0));
      expect((await client.listNodes()).keys, unorderedEquals(['A', 'B']));
    });

    test("should exchange a node's information", () async {
      expect(await client.lookupNode('A'), lessThan(0));
      var port = await client.registerNode('A');
      expect(port, greaterThan(0));
      expect(await daemon.lookupPort('A'), port);
      expect(await client.lookupNode('A'), port);
    });
  });
}
