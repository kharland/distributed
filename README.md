# Distributed
A distributed computing library for Dart.  This is heavily based on [Distribued Erlang](http://erlang.org/doc/reference_manual/distributed.html)

*__Disclaimer__*: This project is still early-stage and there are outstanding bugs blocking some of the functionality in this doc.  Be sure to follow along via the [issue tracker](https://github.com/kharland/distributed/issues)

[![Build Status](https://travis-ci.org/kharland/distributed.svg?branch=master)](https://travis-ci.org/kharland/distributed)
[![Coverage Status](https://coveralls.io/repos/github/kharland/distributed_dart/badge.svg?branch=master)](https://coveralls.io/github/kharland/distributed_dart?branch=master)

## Quick Start
Run the port daemon and spawn the two ping-pong example nodes locally.
```sh
# In terminal window 1
$ dart bin/port_daemon.dart

# In window 2
$ dart examples/ping.dart

# In window 3
$ dart examples/pong.dart
```

The two nodes will send a continuously-incremented counter back and forth forever.

## Overview
### A distributed system
A distributed system consists of one or more __nodes__ communicating with each other.  Nodes connect to one another using unique identifiers consisting of a node's name and ip-address.  This means that two nodes running at the same address may not have the same name.

### Nodes
A node is a single actor in a distributed system. Each node belongs to a single __host machine__, which is a logical grouping of the node's external ip address and the port at which the local port daemon is running.

### The Port Daemon
The __port daemon__ is a name-server for the nodes running at its address.  When a node is spawned, it receives a port from the daemon
and attaches itself to the address: `ws://<ip-address>:<port>`.  Other nodes (__peers__) use the node's name to request its port from the daemon before establishing a connection.

The port daemon allows nodes to retain their names;  If a node goes offline and its port is consumed by another process, it can simply obtain a new port from the daemon.  Peers can reconnect at a later time by querying the port daemon using the same name.

A port daemon _must_ be running wherever nodes are running.   A node will not start without a daemon running.  If the daemon goes offline while a node is running, the node will shut itself down.  __TODO(#58)__

## Using this library
### Programming a node
In the future we plan to support spawning browser nodes, but currently nodes are only supported on the Dart VM.  A quick example of how 
to program a node can be found at `examples/ping.dart` and `examples/pong.dart`.  

To begin, you must always import `package:distributed/distributed.dart` and the current platform (vm or html).
```dart
import 'package:distributed/distributed.dart';
import 'package:distributed.node/platform/vm.dart';
```
Call `Node.spawn` to spawn a node at the current address.  A name is required at minimum.  Ensure the port daemon is running or this step will fail and the program will exit.
```dart
final fooNode = await Node.spawn('foo');
```
When the future completes, the node has registered itself with the local port daemon and is ready to accept or initiate connections.  

You can run this code directly on the VM with `dart path/to/file.dart`.  The node will do nothing at the moment.

#### Connecting to Peers 
If you have the information for another peer, you can connect directly to it:
```dart
final barPeer = new Peer('bar', new HostMachine('123.456.789.0'));
await node.connect(barPeer);
```
#### Sending and Receiving messages
Once connections are established, recieving and sending messages is simple: __TODO(#70)__
```dart
node.receive('Greet').listen((Message message) {
  print('${message.sender} sent: ${message.contents}');

  var response = 'Hello!';
  print('Responding with: $response');
  node.send(message.sender, 'Greet', response);
});
```

Let's break this down: 

-  `Node.receive` tells the node to begin listening for messages in the specified __message category__.  In this case, "Greet" is the 
   category.  Any peer can send a message to this node using the category "Greet" and it will handled by this listener.
-  A `Message` is an object containing a reference to the peer who sent it, the category the message belongs to, and the contents of the 
   message packaged as a string.
-  `Node.send` is used to send a message to a peer.  In this example, we let the peer send the first message while we simply respond 
   with "Hello!".  The signature for `Node.send` is `send(Peer reciever, String category, String contents)`.  __TODO(#68)__
-  __Note__:  We did not have to respond with the category "Greet".  We can use any category name, so long as `message.sender` is 
   listening for it.
   
#### Disconnecting from Peers
- TODO

#### Shutting a node down
- TODO

See the [wiki](https://github.com/kharland/distributed/wiki) for a detailed description of how the system is designed. (_coming soon_)
