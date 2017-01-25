@TestOn("vm")
import 'dart:async';
import 'dart:io';

import 'package:distributed.net/secret.dart';
import 'package:distributed.port_daemon/src/port_daemon.dart';
import 'package:distributed.port_daemon/daemon_client.dart';
import 'package:distributed.port_daemon/daemon_server.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:distributed.utils/logging.dart';
import 'package:test/test.dart';
import 'package:seltzer/platform/vm.dart';
import 'package:quiver/testing/async.dart';

void main() {
  useSeltzerInVm();
  configureLogging(testing: true);

  group('$DaemonServer', () {
    DaemonServer server;
    DaemonClient client;
    PortDaemon daemon;
    File dbFile;

    setUp(() async {
      dbFile = new File('.test.db');
      if (dbFile.existsSync()) {
        dbFile.deleteSync();
      }

      daemon = new PortDaemon(new NodeDatabase(dbFile));
      server = new DaemonServer.withDaemon(daemon, secret: new Secret('test'));
      client = new DaemonClient('', secret: server.secret);
      await server.start();
    });

    tearDown(() {
      server.stop();
      dbFile.deleteSync();
      Future.wait(daemon.nodes.map(daemon.deregisterNode));
    });

    tearDownAll(() {
      if (dbFile.existsSync()) {
        dbFile.deleteSync();
      }
    });

    test('should reject requests with a bad cookie', () async {
      var badClient = new DaemonClient('', secret: new Secret('bad_secret'));
      expect(await badClient.registerNode('A'), lessThan(0));
    });

    test('should be able to ping each other', () async {
      expect(await client.pingDaemon(), isTrue);
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

    test("should deregister a node that fails to ping within its heartbeat",
        () async {
      new FakeAsync().run((fakeAsync) async {
        await client.registerNode('A');
        expect(daemon.lookupPort('A'), greaterThan(0));
        fakeAsync.elapse(ServerHeartbeat.period + const Duration(seconds: 1));
        expect(daemon.lookupPort('A'), lessThan(0));
      });
    });
  });
}
