import 'dart:async';
import 'package:distributed/distributed.dart';
import 'package:distributed/interfaces/command.dart';
import 'package:distributed/platform/io.dart';

import 'package:args/args.dart';
import 'package:distributed/src/repl.dart';

const nodeNames = const <String>['peter', 'gregory', 'richard', 'hendrix'];
const minPort = 9090;

Future main(List<String> args) async {
  configureDistributed();

  var params = _argParser.parse(args);
  Node node = await nodes[params['node']]();
  var peer = params['peer'];
  if (peer.isNotEmpty) {
    await node.createConnection(peers[peer]);
  }

  var nodeAsPeer = node.toPeer();
  var repl = new REPL(
      prefix: '${nodeAsPeer.displayName}>> ',
      printWelcome: () {
        print('enter a command:');
        print('\tc <peer>\tConnect to <peer>');
        print('\td <peer>\tDisconnect from<peer>');
        print('\ts <peer> <command> <args...>\tSend a command to a peer');
        print('\tl \tSee a list of all connected peers');
        print('\tq \tShutdown node and quit.');
      });

  repl.log('Node ${node.name} listening at ${nodeAsPeer.url}...');
  node.onConnect.listen((peer) {
    repl.log('connected to ${peer.displayName}');
  });

  node.onDisconnect.listen((peer) {
    repl.log('disconnected from ${peer.displayName}');
  });

  node.onShutdown.then((_) {
    repl.log('${nodeAsPeer.displayName} successfully shut down.');
  });

  node.receive('square', (Peer peer, Set params) {
    int n = int.parse(params.elementAt(0));
    print('$peer sent square with args $params');
    node.send(peer, 'square_result', [n * n]);
  });

  node.receive('square_result', (Peer peer, Set params) {
    print('$peer sent square_result with args $params');
    print('remote node squared ${params.elementAt(0)}');
  });

  repl.onInput.listen((String input) {
    if (input.trim() == 'q') {
      node.shutdown();
    }

    var args = input.split(' ').map((s) => s.trim()).toList();
    if (args.first.trim() == 'c') {
      if (peers.containsKey(args.last)) {
        repl.log('connecting to ${peers[args.last].displayName}');
        node.createConnection(peers[args.last]);
      } else {
        repl.log('No peer named ${args.last}');
      }
    }

    if (args.first.trim() == 'l') {
      assert(args.length == 1);
      repl.log('Connected peers:');
      for (Peer peer in node.peers) {
        repl.log('- ${peer.displayName} --> ${peer.url}');
      }
    }

    if (args.first.trim() == 'd') {
      node.disconnect(peers[args.last]);
    }

    if (args.first.trim() == 's') {
      if (!nodeNames.contains(args[1])) {
        throw new ArgumentError('No peer named ${args[1]}');
      }
      var peer = peers[args[1]];
      if (!node.peers.contains(peer)) {
        node.createConnection(peer);
        node.onConnect.take(1).last.then((_) {
          node.send(peer, args[2], args.skip(3).toList());
          repl.log('Sent ${peer.displayName} command');
        });
      } else {
        node.send(peer, args[2], args.skip(3).toList());
        repl.log('Sent ${peer.displayName} command');
      }
    }
  });
}

final ArgParser _argParser = new ArgParser()
  ..addOption('node', defaultsTo: '')
  ..addOption('peer', defaultsTo: '')
  ..addOption('nodeName', defaultsTo: 'derp')
  ..addOption('hostName', defaultsTo: 'localhost');

Map<String, Function> nodes = new Map.fromIterable(nodeNames,
    key: (name) => name,
    value: (name) => () => createNode(name, 'localhost', 'cookie',
        port: minPort + nodeNames.indexOf(name)));

Map<String, Peer> peers = new Map.fromIterable(nodeNames,
    key: (name) => name,
    value: (name) =>
        new Peer(name, 'localhost', port: minPort + nodeNames.indexOf(name)));
