import 'dart:async';

import 'dart:io';
import 'package:distributed.net/secret.dart';
import 'package:distributed.node/platform/vm.dart';
import 'package:distributed.node/src/connection/connection_channels.dart';
import 'package:distributed.node/src/connection/connection_strategy.dart';
import 'package:distributed.node/src/node_finder.dart';
import 'package:distributed.node/src/message/message_channels_controller.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:test/test.dart';

import 'src/connection_strategy_test.dart' as connection_strategy_test;

TestNodeFinder nodeFinder;
ConnectionStrategy createStrategy([List<String> inNetworkPeers = const []]) =>
    new SearchForNode(
      new TestNodeFinder(inNetworkPeers),
      new TestConnectionChannelsProvider(),
    );

void main() {
  configureDistributed();
  group('$SearchForNode', () {
    connection_strategy_test.main(
      setup: createStrategy,
      teardown: () async {},
    );
  });
}

class TestConnectionChannelsProvider
    implements ConnectionChannelsProvider<Message> {
  final MessageChannelsController _messageChannelsController =
      new MessageChannelsController();

  @override
  Future<ConnectionChannels<Message>> createFromSocket(_) =>
      new Future.value(_messageChannelsController.foreign);

  @override
  Future<ConnectionChannels<Message>> createFromUrl(String url,
          {Secret secret: Secret.acceptAny}) =>
      new Future.value(_messageChannelsController.foreign);
}

class TestNodeFinder implements NodeFinder {
  final List<String> _networkPeers;

  TestNodeFinder([this._networkPeers = const []]);

  @override
  Future<InternetAddress> findNodeAddress(String nodeName) =>
      new Future<InternetAddress>.value(_networkPeers.contains(nodeName)
          ? new InternetAddress('127.0.0.1')
          : null);

  @override
  Future<int> findNodePort(String nodeName) async =>
      _networkPeers.contains(nodeName) ? 123 : Ports.invalidPort.toInt();
}
