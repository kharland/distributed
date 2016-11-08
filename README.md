# distributed_dart
Simple distributed programming in Dart. (Work in Progress).

[![Build Status](https://travis-ci.org/kharland/distributed_dart.svg?branch=master)](https://travis-ci.org/kharland/distributed_dart)
[![Coverage Status](https://coveralls.io/repos/github/kharland/distributed_dart/badge.svg?branch=master)](https://coveralls.io/github/kharland/distributed_dart?branch=master)

## Quickstart

A distributed system is comprised of a number of independent *Nodes*.  A Node can be a server or a simple process sharing a machine with many other Nodes. This framework provides a simple message passing scheme which allows Nodes to interact with one another.

A working Node demo can be found at `bin/io_node_demo.dart`. You can launch mutliple Nodes and connect/disconnect to each other in the terminal.

```dart
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
```

```sh
# In a terminal named 'Derp'
dart bin/io_node_demo.dart --name='derp'
-- Node derp listening at ws://localhost:8080...
derp@localhost>> connect herp@localhost:8081
-- connecting to herp@localhost
-- connected to herp@localhost
derp@localhost>> list
-- Connected peers:
-- 1. herp@localhost --> ws://localhost:8081
derp@localhost>> send herp@localhost:8081 square 23
-- Sent herp@localhost command: square [23]
-- herp@localhost computed square_result as 529
derp@localhost>> send herp@localhost:8081 reverse 29999 2999 2999
-- Sent herp@localhost command: reverse [29999, 2999, 2999]
-- herp@localhost reversed items as (2999, 2999, 29999)
```

```sh
# In a terminal named 'Herp'
-- Node herp listening at ws://localhost:8081...
-- connected to derp@localhost
-- derp@localhost asked us to square 23}
-- responding to derp@localhost with 529
-- derp@localhost asked us to reverse [29999, 2999, 2999]
-- responding with [2999, 2999, 29999]
herp@localhost>>
