import 'package:distributed/src/port_daemon/node_database.dart';
import 'package:distributed.objects/objects.dart';
import 'package:test/test.dart';

void main() {
  group('$NodeDatabase', () {
    NodeDatabase db;
    NodePorts nodePorts;
    const nodeName = 'a';

    setUp(() {
      db = new NodeDatabase();
      nodePorts = new NodePorts(1, 2, 3);
    });

    group('getPorts', () {
      test('should return ${NodePorts.Null} for an unregistered node',
          () async {
        expect(await db.getPorts(nodeName), NodePorts.Null);
      });

      test('should return the ports for a registered node', () async {
        expect(await db.getPorts(nodeName), NodePorts.Null);
        expect(await db.registerNode(nodeName, nodePorts), isEmpty);
        expect(await db.getPorts(nodeName), nodePorts);
      });
    });

    group('registerNode', () {
      test('should register an unregistered node', () async {
        expect(await db.registerNode(nodeName, nodePorts), isEmpty);
        expect(await db.getPorts(nodeName), nodePorts);
      });

      test('should fail to register an already registered node', () async {
        expect(await db.registerNode(nodeName, nodePorts), isEmpty);
        expect(await db.getPorts(nodeName), nodePorts);
        expect(await db.registerNode(nodeName, nodePorts), isNotEmpty);
        expect(db.registrants, hasLength(3));
      });
    });

    group('deregisterNode', () {
      test('should deregister a registered node', () async {
        expect(await db.registerNode(nodeName, nodePorts), isEmpty);
        expect(await db.getPorts(nodeName), nodePorts);
        await db.deregisterNode(nodeName);
        expect(await db.getPorts(nodeName), NodePorts.Null);
      });
    });
  });
}
