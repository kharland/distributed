//
//import 'dart:async';
//import 'dart:io';
//
//import 'package:args/args.dart';
//import 'package:distributed.node/src/logging.dart';
//import 'package:distributed.port_daemon/daemon_server.dart';
//import 'package:distributed.port_daemon/src/port_daemon.dart';
//import 'package:fixnum/fixnum.dart';
//
//Future main(List<String> args) async {
//  var argResults = _parseArgs(args);
//  var port = Int64.parseInt(argResults['port']);
//
//  configureLogging();
//
//  var server = new DaemonServer(
//      portDaemon: new PortDaemon(new NodeDatabase(new File('.node.db'))),
//  );
//
//  // spawn daemon
//  server.start();
//  print("Daemon listening at ${server.url}");
//}
//
//ArgResults _parseArgs(List<String> args) => (new ArgParser()
//  ..addOption('port', defaultsTo: DaemonServer.defaultPort.toString()))
//    .parse(args);
