import 'dart:async';
import 'package:distributed/distributed.dart';
import 'package:distributed/platform/io.dart';

import 'package:args/args.dart';

Future main(List<String> args) async {
  configureDistributed();

  var params = _argParser.parse(args);

  Node nnode = await createNode(
      params['name'], params['hostname'], params['cookie'],
      port: int.parse(params['port']), hidden: params['hidden'] != null);

  InteractiveNode node =
      new InteractiveNode(nnode, prompt: '${nnode.toPeer().displayName}>> ');

  node.receive('square', (Peer peer, Set params) {
    int n = int.parse(params.elementAt(0));
    int result = n * n;
    node.log('${peer.displayName} asked us to square $n}');
    node.log('responding to ${peer.displayName} with $result');
    node.send(peer, 'square_result', [result]);
  });

  node.receive('square_result', (Peer peer, Set params) {
    node.log('${peer.displayName} computed square_result as '
        '${params.elementAt(0)}');
  });

  node.receive('reverse', (Peer peer, Set params) {
    List<int> items = params.map(int.parse).toList();
    node.log('${peer.displayName} asked us to reverse $items');
    items = items.reversed.toList();
    node.log('responding with $items');
    node.send(peer, 'reverse_result', [items]);
  });

  node.receive('reverse_result', (Peer peer, Set params) {
    node.log('${peer.displayName} reversed items as ${params.elementAt(0)}');
  });
}

final ArgParser _argParser = new ArgParser()
  ..addOption('cookie', defaultsTo: 'cookie')
  ..addOption('name', defaultsTo: 'derp')
  ..addOption('hostname', defaultsTo: 'localhost')
  ..addOption('hidden', defaultsTo: null)
  ..addOption('port', defaultsTo: '8080');
