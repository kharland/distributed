import 'dart:async';

import 'package:distributed/src/objects/interfaces.dart';
import 'package:distributed/src/monitoring/logging.dart';
import 'package:distributed/src/port_daemon/port_daemon.dart';
import 'package:distributed/src/port_daemon/port_daemon_client.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:test/test.dart';

void main() {
  PortDaemon daemon;
  PortDaemonClient clientA;
  PortDaemonClient clientB;

  Future commonSetUp() async {
    daemon = await PortDaemon.spawn(new Logger.disabled());
    clientA =
        new PortDaemonClient(name: 'A', daemonHost: HostMachine.localHost);
    clientB =
        new PortDaemonClient(name: 'B', daemonHost: HostMachine.localHost);
  }

  Future commonTearDown() async {
    await clientA.deregister();
    await clientB.deregister();
    daemon.stop();
  }

  group('$PortDaemonClient', () {
    setUp(() => commonSetUp());

    tearDown(() => commonTearDown());

    test('should be able to ping the daemon', () async {
      expect(await clientA.isDaemonRunning, isTrue);
    });
  });

  group('$PortDaemon', () {
    setUp(() => commonSetUp());

    tearDown(() => commonTearDown());

    test('nodes should return the nodes registered with the daemon', () async {
      expect(daemon.nodes, isEmpty);
      await clientA.register();
      await clientB.register();
      expect(daemon.nodes, ['A', 'B']);
    });

    test('should register a node', () async {
      expect(await clientA.register(), greaterThan(0));
      expect(await daemon.getPort('A'), greaterThan(0));
    });

    test('should fail to register a currently registered node', () async {
      expect(await clientA.register(), greaterThan(0));
      expect(await clientA.register(), Ports.error);
    });

    test('should be able to deregister a node', () async {
      expect(await clientA.register(), greaterThan(0));
      expect(await daemon.getPort('A'), greaterThan(0));
      expect(await clientA.deregister(), true);
      expect(await daemon.getPort('A'), Ports.error);
    });

    test('should exchange the list of nodes registered on the server',
        () async {
      expect(await clientA.getNodes(), isEmpty);
      expect(await clientA.register(), greaterThan(0));
      expect(await clientB.register(), greaterThan(0));
      expect((await clientA.getNodes()).keys, unorderedEquals(['A', 'B']));
    });

    test("should exchange a node's information", () async {
      expect(await clientA.lookup('A'), '');
      var port = await clientA.register();
      expect(port, greaterThan(0));
      expect(await daemon.getPort('A'), port);
      expect(await clientA.lookup('A'), 'ws://localhost:$port');
    });
  });
}
