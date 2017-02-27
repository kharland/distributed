@TestOn("vm")
import 'dart:async';
import 'dart:io';

import 'package:distributed.node/src/logging.dart';
import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:distributed.port_daemon/port_daemon_client.dart';
import 'package:distributed.port_daemon/src/express_daemon.dart';
import 'package:distributed.port_daemon/src/database_helpers.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:quiver/testing/async.dart';
import 'package:seltzer/platform/vm.dart';
import 'package:test/test.dart';

void main() {
  useSeltzerInVm();
  configureLogging(testing: true);

  group('$ExpressDaemon', () {
    ExpressDaemon server;
    PortDaemonClient client;
    DatabaseHelpers portDaemon;
    File dbFile;

    setUp(() async {
      dbFile = new File('.test.db');
      if (dbFile.existsSync()) {
        dbFile.deleteSync();
      }

      var daemonHostMachine = new HostMachine();
      server = new PortDaemon(hostMachine: daemonHostMachine);
      client = new PortDaemonClient('', daemonHostMachine);
      await server.start();
    });

    tearDown(() async {
      server.stop();
      dbFile.deleteSync();
      Future.wait(portDaemon.nodes.map(portDaemon.deregisterNode));
    });

    tearDownAll(() async {
      if (dbFile.existsSync()) {
        dbFile.deleteSync();
      }
    });

    test('should be able to ping each other', () async {
      expect(await client.pingDaemon(), isTrue);
    });

    test('should register a node', () async {
      expect(await client.registerNode('A'), greaterThan(0));
      expect(await portDaemon.lookupPort('A'), greaterThan(0));
    });

    test('should fail to register a currently registered node', () async {
      expect(await client.registerNode('A'), greaterThan(0));
      expect(await client.registerNode('A'), Ports.error);
    });

    test('should deregister a node', () async {
      expect(await client.registerNode('A'), greaterThan(0));
      expect(await portDaemon.lookupPort('A'), greaterThan(0));
      expect(await client.deregisterNode('A'), true);
      expect(await portDaemon.lookupPort('A'), Ports.error);
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
      expect(await portDaemon.lookupPort('A'), port);
      expect(await client.lookupNode('A'), port);
    });

    test("should deregister a node that fails to ping within its heartbeat",
        () async {
      new FakeAsync().run((fakeAsync) async {
        await client.registerNode('A');
        expect(portDaemon.lookupPort('A'), greaterThan(0));
        fakeAsync.elapse(ServerHeartbeat.period + const Duration(seconds: 1));
        expect(portDaemon.lookupPort('A'), lessThan(0));
      });
    });
  }, skip: 'broken and lazy');
}
