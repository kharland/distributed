import 'dart:async';
import 'dart:io';

import 'package:distributed.port_mapping_daemon/src/database/database.dart';
import 'package:distributed.port_mapping_daemon/src/database/serializer.dart';
import 'package:fixnum/fixnum.dart';

/// An interface for interacting with the database of nodes registered to the
/// local port mapping daemon.
class Daemon {
  final Database<String, Int64> _database;

  Daemon(this._database);

  /// The set of names of all nodes registered with this daemon.
  Set<String> get nodes => _database.keys;

  /// Assigns a port to a new node named [name].
  ///
  /// Returns a future that completes with the port number.
  Future<Int64> registerNode(String name) async {
    Int64 port;
    if ((port = await lookupPort(name)) > 0) {
      throw new ArgumentError('$name is already registered to port $port');
    }
    return _database.insert(name, await _getUnusedPort());
  }

  /// Frees the port held by the node named [name].
  ///
  /// An argument error is thrown if such a node does not exist.
  Future<Null> deregisterNode(String name) async {
    if (await lookupPort(name) < 0) {
      throw new ArgumentError('$name is not registered');
    }
    await _database.remove(name);
  }

  /// Returns the port for the node named [nodeName].
  ///
  /// If no node is found, returns -1.
  Future<Int64> lookupPort(String nodeName) async =>
      await _database.get(nodeName) ?? -1;

  /// Returns the next available unused port.
  Future<Int64> _getUnusedPort() =>
      ServerSocket.bind('localhost', 0).then((socket) {
        var port = socket.port;
        socket.close();
        return new Int64(port);
      });
}

class NodeDatabase extends MemoryDatabase<String, Int64> {
  NodeDatabase(File databaseFile)
      : super(databaseFile,
            recordSerializer: new RecordSerializer(
              new StringSerializer(),
              new Int64Serializer(),
            ));
}
