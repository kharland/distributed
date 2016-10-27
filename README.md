# distributed_dart
Simple distributed programming in Dart. (Work in Progress).

[![Build Status](https://travis-ci.org/kharland/distributed_dart.svg?branch=master)](https://travis-ci.org/kharland/distributed_dart)

## Quickstart

A distributed system is comprised of a number of independent *Nodes*.  A Node
can be a server in itself or a simple process sharing a machine with many other
Nodes. This framework (soon) provides a simple message passing scheme which 
allows Nodes to interact with one another.

A working Node demo can be found at `bin/io_node.dart`. You can launch two or 
more Nodes and connect/disconnect to each other in the terminal.

```sh
# terminal tab/window 'peter'
dart bin/io_node.dart --node='peter'

# terminal tab/window 'richard;
dart bin/io_node.dart --node='richard'

# Possible names are: peter, gregory, richard and hendrix
```

You'll see a list of commands that you can issue to a a node.  Connect peter to richard by typing `c richard` into the terminal for peter.


```sh
enter a command:
	c <peer>	Connect to <peer>
	d <peer>	Disconnect from<peer>
	l 	See a list of all connected peers
	q 	Shutdown node and quit.
Node peter@localhost listening...
>> c richard
connecting to richard@localhost
connected to richard@localhost
>> 
```
```sh
enter a command:
	c <peer>	Connect to <peer>
	d <peer>	Disconnect from<peer>
	l 	See a list of all connected peers
	q 	Shutdown node and quit.
Node richard@localhost listening...
connected to peter@localhost
>> 
```

...
