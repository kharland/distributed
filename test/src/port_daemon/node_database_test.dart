import 'dart:async';
import 'package:distributed/src/port_daemon/database_errors.dart';
import 'package:distributed/src/port_daemon/node_database.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:quiver/testing/async.dart';
import 'package:test/test.dart';

void main() {
  group('$NodeDatabase', () {
    NodeDatabase db;

    setUp(() async {
      db = new NodeDatabase();
    });

    group('getPort', () {
      test('should return ${Ports.error} for an unregistered node', () async {
        expect(await db.getPort('a'), Ports.error);
      });

      test('should return the port for a registered node', () async {
        expect(await db.getPort('a'), Ports.error);
        var registration = await db.registerNode('a');
        expect(await db.getPort('a'), registration.port);
      });
    });

    group('registerNode', () {
      test('should register an unregistered node', () async {
        var registration = await db.registerNode('a');
        expect(registration.port, greaterThan(0));
        expect(registration.error, isEmpty);
      });

      test('should fail to register an already registered node', () async {
        await db.registerNode('a');
        expect(await db.getPort('a'), greaterThan(0));

        var registration = await db.registerNode('a');
        expect(registration.port, Ports.error);
        expect(registration.error, NODE_ALREADY_EXISTS);
      });
    });

    group('deregisterNode', () {
      test('should deregister a registered node', () async {
        await db.registerNode('a');
        expect(await db.getPort('a'), greaterThan(0));
        var error = await db.deregisterNode('a');
        expect(error, isEmpty);
        expect(await db.getPort('a'), Ports.error);
      });

      test('should fail to deregister an unregistered node', () async {
        expect(await db.getPort('a'), lessThan(0));
        expect(await db.deregisterNode('a'), NODE_NOT_FOUND);
        expect(await db.getPort('a'), lessThan(0));
      });
    });
  });
}
