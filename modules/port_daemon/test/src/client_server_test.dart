@TestOn("vm")
import 'dart:async';

import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:distributed.port_daemon/port_daemon_client.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:seltzer/platform/vm.dart';
import 'package:test/test.dart';

void main() {
  useSeltzerInVm();

  final hostMachine = createHostMachine('localhost', 9000);
  PortDaemon daemon;
  PortDaemonClient client;

  Future commonSetUp() async {
    daemon = new PortDaemon(hostMachine: hostMachine);
    client = new PortDaemonClient(daemonHostMachine: hostMachine);
    await daemon.start();
  }

  Future commonTearDown() async {
    daemon.stop();
    Future.wait(daemon.nodes.map(daemon.deregisterNode));
  }

  group('$PortDaemonClient', () {
    setUp(() => commonSetUp());

    tearDown(() => commonTearDown());

    test('should be able to ping the daemon', () async {
      expect(await client.isDaemonRunning, isTrue);
    });
  });

  group('$PortDaemon', () {
    setUp(() => commonSetUp());

    tearDown(() => commonTearDown());

    test('nodes should return the nodes registered with the daemon', () async {
      expect(daemon.nodes, isEmpty);
      await client.register('A');
      await client.register('B');
      expect(daemon.nodes, ['A', 'B']);
    });

    test('should register a node', () async {
      expect(await client.register('A'), greaterThan(0));
      expect(await daemon.lookupPort('A'), greaterThan(0));
    });

    test('should fail to register a currently registered node', () async {
      expect(await client.register('A'), greaterThan(0));
      expect(await client.register('A'), Ports.error);
    });

    test('should be able to deregister a node', () async {
      expect(await client.register('A'), greaterThan(0));
      expect(await daemon.lookupPort('A'), greaterThan(0));
      expect(await client.deregister('A'), true);
      expect(await daemon.lookupPort('A'), Ports.error);
    });

    test('should exchange the list of nodes registered on the server',
        () async {
      expect(await client.getNodes(), isEmpty);
      expect(await client.register('A'), greaterThan(0));
      expect(await client.register('B'), greaterThan(0));
      expect((await client.getNodes()).keys, unorderedEquals(['A', 'B']));
    });

    test("should exchange a node's information", () async {
      expect(await client.lookup('A'), lessThan(0));
      var port = await client.register('A');
      expect(port, greaterThan(0));
      expect(await daemon.lookupPort('A'), port);
      expect(await client.lookup('A'), port);
    });
  });
}
