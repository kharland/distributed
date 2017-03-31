import 'dart:async';

import 'package:distributed/src/monitoring/logging.dart';
import 'package:distributed/src/port_daemon/client.dart';
import 'package:distributed/src/port_daemon/port_daemon.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:test/test.dart';

void main() {
  PortDaemon daemon;
  PortDaemonClient client;

  Future commonSetUp() async {
    daemon = await PortDaemon.spawn(new Logger.disabled());
    client = new PortDaemonClient(daemon.url);
  }

  Future commonTearDown() async {
    await client.deregisterNode('A');
    await client.deregisterNode('B');
    daemon.stop();
  }

  group('$PortDaemonClient', () {
    setUp(() => commonSetUp());

    tearDown(() => commonTearDown());

    test('should be able to ping the daemon', () async {
      expect(await client.pingDaemon(), isTrue);
    });
  });

  group('$PortDaemon', () {
    setUp(() => commonSetUp());

    tearDown(() => commonTearDown());

    group('registerNode', () {
      test('should register a node', () async {
        expect(await client.getNodeUrl('A'), isEmpty);
        expect(await client.registerNode('A'), greaterThan(0));
        expect(await client.getNodeUrl('A'), isNotEmpty);
      });

      test('should fail if a node with the same name is registered', () async {
        expect(await client.registerNode('A'), greaterThan(0));
        expect(await client.registerNode('A'), Ports.error);
      });
    });

    test("getNodeUrl should return a node's url", () async {
      expect(await client.getNodeUrl('A'), '');
      var port = await client.registerNode('A');
      expect(port, greaterThan(0));
      expect(await client.getNodeUrl('A'), 'ws://localhost:$port');
      await client.deregisterNode('A');
      expect(await client.getNodeUrl('A'), '');
    });

    test('should be able to deregister a node', () async {
      expect(await client.registerNode('A'), greaterThan(0));
      expect(await client.getNodeUrl('A'), isNotEmpty);
      expect(await client.deregisterNode('A'), true);
      expect(await client.getNodeUrl('A'), isEmpty);
    });
  });
}
