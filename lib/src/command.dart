import 'package:args/args.dart';
import 'package:distributed/interfaces/node.dart';
import 'package:distributed/interfaces/peer.dart';

/// Parses and runs commands for an [InteractiveNode].
class CommandRunner {
  final ArgParser _parser = new ArgParser();
  final Map<String, Command> _commandsByName = <String, Command>{};

  CommandRunner();

  String get usage => _parser.commands.values.map((c) => c.usage).toString();

  void addCommand(Command command) {
    _parser.addCommand(command.name, command.parser);
    _commandsByName[command.name] = command;
  }

  void parseAndRun(List<String> args) {
    var result = _parser.parse(args);
    if (result.command != null) {
      _commandsByName[result.command.name].execute(result.command);
    }
  }
}

abstract class Command {
  String get name;
  ArgParser get parser;
  void execute(ArgResults args);

  /// Helper to parse a [Peer] from [name] while handling errors.
  static Peer _tryToParsePeer(String name, StringSink errorSink) {
    Peer peer;
    try {
      peer = new Peer.fromNamesAndPort(name);
    } on FormatException catch (err) {
      errorSink.write(err);
      return null;
    }
    return peer;
  }
}

class QuitCommand implements Command {
  final Node _node;

  QuitCommand(this._node);

  @override
  String get name => 'quit';

  @override
  ArgParser get parser => null;

  @override
  void execute(ArgResults args) {
    _node.shutdown();
  }
}

/// Disconnects a node from a specified peer.
class DisconnectCommand implements Command {
  final Node _node;
  final StringSink _errorSink;

  @override
  final ArgParser parser = new ArgParser()
    ..addOption('peer',
        abbr: 'p',
        help: 'the full name of the peer to disconnect from, with the format'
            '<name>@<hostname>:<port>.  Port is optional (defaults 8080)',
        splitCommas: true,
        allowMultiple: true,
        defaultsTo: '')
    ..addOption('name',
        abbr: 'n',
        help: 'the name of the peer to disconnect from.',
        splitCommas: true,
        allowMultiple: true,
        defaultsTo: '');

  DisconnectCommand(this._node, this._errorSink);

  @override
  String get name => 'disconnect';

  @override
  void execute(ArgResults args) {
    if (args.wasParsed('name')) {
      List<String> names = args['name'] as List<String>;
      names.forEach((String name) {
        _disconnect((Peer p) => p.name == name);
      });
    }
    if (args.wasParsed('peer')) {
      List<String> names = args['peer'] as List<String>;
      names.forEach((String name) {
        Peer peer = Command._tryToParsePeer(name, _errorSink);
        if (peer == null) {
          _errorSink.write('Unable to parse peer $name');
          return;
        }
        _disconnect((Peer p) =>
            p.displayName == peer.displayName && p.port == peer.port);
      });
    }
  }

  void _disconnect(bool filter(Peer peer)) {
    var peers = _node.peers.where(filter);
    if (peers.length > 1) {
      _errorSink.write('Multiple peers named ${peers.first.name}. Use --peer to'
          'disambiguate.');
    } else if (peers.isEmpty) {
      _errorSink.write('No matching peers found.');
    } else {
      _node.disconnect(peers.single);
    }
  }
}

class ConnectCommand implements Command {
  final Node _node;
  final StringSink _errorSink;

  @override
  final ArgParser parser = new ArgParser()
    ..addOption('peer',
        abbr: 'p',
        help: 'the full name of the peer to disconnect from, with the format'
            '<name>@<hostname>:<port>.  Port is optional (defaults 8080).',
        splitCommas: true,
        allowMultiple: true,
        defaultsTo: '')
    ..addOption('name',
        abbr: 'n',
        help: 'The name of the peer to disconnect from.  '
            'Only one of --peer or --name is used (default peer)',
        splitCommas: true,
        allowMultiple: true,
        defaultsTo: '');

  ConnectCommand(this._node, this._errorSink);

  @override
  String get name => 'connect';

  @override
  void execute(ArgResults args) {
    if (args.wasParsed('peer')) {
      List<String> names = args['peer'] as List<String>;
      names.forEach((String name) {
        Peer peer = Command._tryToParsePeer(name, _errorSink);
        if (peer == null) {
          _errorSink.write('Unable to parse peer $name');
          return;
        }
        _node.createConnection(peer);
      });
    } else {
      _errorSink.write('No peer specified.');
    }
  }
}

class SendCommand implements Command {
  final Node _node;
  final StringSink _errorSink;

  SendCommand(this._node, this._errorSink);

  @override
  final ArgParser parser = new ArgParser()
    ..addOption('peer',
        abbr: 'p',
        help: 'the full name of the peer to disconnect from, with the format'
            '<name>@<hostname>:<port>.  Port is optional (defaults 8080).  '
            'Only one of --peer or --name is used (default peer)',
        defaultsTo: '')
    ..addOption('name',
        abbr: 'n',
        help: 'The name of the peer to disconnect from.  '
            'Only one of --peer or --name is used (default peer)',
        splitCommas: true,
        allowMultiple: true,
        defaultsTo: '');

  @override
  String get name => 'send';

  @override
  void execute(ArgResults args) {
    Peer peer;
    if (args.wasParsed('peer')) {
      peer = Command._tryToParsePeer(args['peer'], _errorSink);
    } else if (args.wasParsed('name')) {
      if (args.rest.isEmpty) {
        _errorSink.write('Cannot send an empty command');
        return;
      }

      String userCommand = args.rest.first;
      List<String> params = args.rest.skip(1).toList();
      args['name'].forEach((String name) {
        var peers = _node.peers.where((p) => p.name == name);
        if (peers.length > 1) {
          _errorSink
              .write('Multiple peers named ${peers.first.name}. Use --peer to'
                  'disambiguate.');
          return;
        } else if (peers.isEmpty) {
          _errorSink.write('Not connected to any peer named ${args['name']}');
          return;
        }
        _node.send(peers.single, userCommand, params);
      });
    } else {
      _errorSink.write('No peer specified.');
    }
  }
}

class ListCommand implements Command {
  final Node _node;
  final StringSink _log;

  ListCommand(this._node, this._log);

  @override
  String get name => 'list';

  @override
  ArgParser get parser => null;

  @override
  void execute(ArgResults args) {
    for (int peerno = 0; peerno < _node.peers.length; peerno++) {
      var peer = _node.peers.elementAt(peerno);
      _log.write('${peerno+1}. ${peer.displayName} --> ${peer.url}');
    }
  }
}
